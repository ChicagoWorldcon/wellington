# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2019 AJ Esler
# Copyright 2021 DisCon III
#
# Licensed under the Apache License, Version 2.0 (the "License");
# 23-Oct-21 FNB add charge type to track membership vs site seleciton payments

# Money::StartStripeCheckout creates a pending charge record against a User for the Stripe integrations
# and sets them up to check out with Stripe.
# Truthy returns mean the user can be safely sent on to the checkout flow, otherwise check #errors for failure details.

class Money::StartStripeCheckout
  attr_reader :reservation, :user, :charge_amount, :charge, :amount_owed, :success_url, :cancel_url, :site

  def initialize(reservation:, user:, amount_owed:, success_url:, cancel_url:, charge_amount: nil, site: nil)
    @reservation = reservation
    @user = user
    @charge_amount = charge_amount || amount_owed
    @amount_owed = amount_owed
    @success_url = success_url
    @cancel_url = cancel_url
    @site = site

  end

  def call
    setup_stripe_customer

    check_charge_amount unless errors.any?
    create_checkout_session unless errors.any?
    
    charge_state_params = if errors.any?
      {
        state: ::Charge::STATE_FAILED,
        comment: error_message,
      }
    else
      {
        state: ::Charge::STATE_PENDING,
        comment: "Pending stripe payment",
      }
    end

    @charge = ::Charge.stripe.create!({
      user: user,
      reservation: reservation,
      stripe_id: @checkout_session.id,
      amount: charge_amount,
      site: site,                             ##################################################
    }.merge(charge_state_params))

    checkout_url.present?
  end

  def error_message
    errors.to_sentence
  end

  def errors
    @errors ||= []
  end

  def checkout_url
    @checkout_session['url']
  end

  private

  def check_charge_amount
    if !charge_amount.present?
      errors << "charge amount is missing"
    end
    if charge_amount <= 0
      errors << "amount must be more than 0 cents"
    end
    if charge_amount > amount_owed
      errors << "refusing to overpay for reservation"
    end
  end

  def create_checkout_session
    @checkout_session = Stripe::Checkout::Session.create({
      line_items: [
        {
          currency: ENV.fetch('STRIPE_CURRENCY'),
          amount: charge_amount.cents,
          name: site ? "Site Selection":reservation.membership.to_s,
          quantity: 1,
        },
      ],
      payment_method_types: [
        'card',
        'wechat_pay',                                                   ################## Alipay would go here, or anything else.
      ],
      payment_method_options: {
        wechat_pay: {
          client: 'web',
        }
      },
      mode: 'payment',
      customer: user.stripe_id,
      success_url: success_url,
      cancel_url: cancel_url,
    })
  end
  
  def setup_stripe_customer
    if !user.stripe_id.present?
      stripe_customer = Stripe::Customer.create(email: user.email)
      user.update!(stripe_id: stripe_customer.id)
    end
  rescue Stripe::StripeError => e
    errors << e.message.to_s
    @charge.stripe_response = json_to_hash(e.response)
    @charge.comment = "Failed to setup customer - #{e.message}"
  end

  def json_to_hash(obj)
    JSON.parse(obj.to_json)
  rescue
    {}
  end

  def fully_paid?
    @charge.successful? && (amount_owed - charge_amount) <= 0
  end
end
