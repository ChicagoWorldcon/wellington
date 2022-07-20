require 'rails_helper'

RSpec.describe "TokenPurchases", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/token_purchase/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/token_purchase/create"
      expect(response).to have_http_status(:success)
    end
  end

end
