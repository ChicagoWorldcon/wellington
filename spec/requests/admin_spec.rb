require "rails_helper"

RSpec.describe "Admins", type: :request do
  describe "GET /index" do
    it "forbids unauthenticated access" do
      get "/admin"
      expect(response).to have_http_status(:forbidden)
    end
  end
end
