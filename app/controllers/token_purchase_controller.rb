class TokenPurchaseController < ApplicationController
  before_action :lookup_reservation!
  before_action :lookup_election!

  def new; end

  def create
    # we check for an existing token first
    if @reservation.site_selection_tokens.for_election(@election).present?
      flash[:error] = "You cannot buy more than one token for a site selection. Your card has not been charged."
      redirect_to reservation_site_selection_tokens_path
      return
    end

    TokenPurchase.transaction do
      @purchase = TokenPurchase.for_election!(@reservation, @election)
      unless @purchase.present?
        flash[:error] = "No tokens are available for #{@election_name}. Your card has not been charged."
        raise ActiveRecord::Rollback
      end

      begin
        stripe_customer = Stripe::Customer.create(email: params[:stripeEmail])
        card_response = Stripe::Customer.create_source(stripe_customer.id, source: params[:stripeToken])
        charge = Stripe::Charge.create(
          description: "Purchase site selection token for #{@election_name}",
          currency: $currency,
          customer: stripe_customer.id,
          source: card_response.id,
          amount: @outstanding_amount.cents,
          metadata: {
            "product" => "site selection token",
            "election" => @election,
            "member_number" => @reservation.membership_number
          }
        )
      rescue Stripe::StripeError => e
        flash[:error] = e.message
        raise ActiveRecord::Rollback
      end
      @purchase.charge_stripe!(charge_id: charge[:id], price_cents: charge[:amount])
      flash[:notice] = "You can now vote in the #{@election_name} election."

      @purchased_token = @purchase.site_selection_token if @purchase.present?
      trigger_site_selection_purchase_mailer(charge)
    end
    redirect_to reservation_site_selection_tokens_path
  end

  private

  def lookup_election!
    @election = params[:election]
    @election_name = t("rights.site_selection.#{@election}.name")
    @election_info = $site_selection_info[@election]
    @outstanding_amount = Money.new(@election_info[:price])
  end

  def trigger_site_selection_purchase_mailer(_charge)
    SiteSelectionMailer.bought_token(
      reservation: @reservation,
      voter_id: @purchased_token.voter_id,
      token: @purchased_token.token,
      election_name: @election_name,
      election_info: @election_info
    ).deliver_later
  end
end
