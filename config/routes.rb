# frozen_string_literal: true

# Copyright 2019 Andrew Esler (ajesler)
# Copyright 2019 Steven C Hartley
# Copyright 2020 Matthew B. Gray
# Copyright 2021 Fred Bauer
#
# Licensed under the Apache License, Version 2.0 (the "License");
#
# 13-June-21 FNB added hotel


require "sidekiq/web"
require "sidekiq-scheduler/web"

# For more information about routes, see https://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  root to: "landing#index"

  # Sidekiq is our jobs server and keeps tabs on backround tasks
  if ENV["SIDEKIQ_USER"].present? && ENV["SIDEKIQ_PASSWORD"].present?
    # Mounting /sidekiq with basic auth
    mount Sidekiq::Web, at: "/sidekiq"

    Sidekiq::Web.use Rack::Auth::Basic  do |username, password|
      user_provided = ::Digest::SHA256.hexdigest(username)
      user_expected = ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USER"])

      password_provided = ::Digest::SHA256.hexdigest(password)
      password_expected = ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"])

      user_ok = ActiveSupport::SecurityUtils.secure_compare(user_provided, user_expected)
      password_ok = ActiveSupport::SecurityUtils.secure_compare(password_provided, password_expected)

      (user_ok && password_ok)
    end
  elsif ENV["SIDEKIQ_NO_PASSWORD"].present?
    # Mounting /sidekiq without password
    mount Sidekiq::Web, at: "/sidekiq"
  else
    # Not mounting /sidekiq
  end

  # Sets routes for account management actions.
  # This order seems to matter for tests.
  devise_for :users
  devise_for :supports

  get "/login/:email/:key", to: "user_tokens#kansa_login_link", email: /[^\/]+/, key: /[^\/]+/
  resources :user_tokens, only: [:new, :show, :create], id: /[^\/]+/ do
    get :logout, on: :collection
  end

  resources :credits
  resources :landing
  resources :memberships
  resources :themes
  resources :upgrades
  resources :hugo_packet, id: /[^\/]+/
  resources :hotel, id: /[^\/]+/

  resources :reservations do
    post :reserve_with_cheque, on: :collection
    resources :charges do
      get :stripe_checkout_success, on: :collection
      get :stripe_checkout_cancel, on: :collection
    end
    resources :finalists, id: /[^\/]+/
    resources :nominations, id: /[^\/]+/
    resources :upgrades
  end

  post '/stripe_webhook', to: 'stripe_webhooks#receive'

  # /operator are maintenance routes for support people
  scope :operator do
    resources :reservations do
      resources :credits
      resources :set_memberships
      resources :transfers, id: /[^\/]+/
      resources :rights
    end
  end
end
