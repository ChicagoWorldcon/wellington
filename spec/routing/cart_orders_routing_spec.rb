require "rails_helper"

RSpec.describe CartOrdersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/cart_orders").to route_to("cart_orders#index")
    end

    it "routes to #new" do
      expect(get: "/cart_orders/new").to route_to("cart_orders#new")
    end

    it "routes to #show" do
      expect(get: "/cart_orders/1").to route_to("cart_orders#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/cart_orders/1/edit").to route_to("cart_orders#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/cart_orders").to route_to("cart_orders#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/cart_orders/1").to route_to("cart_orders#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/cart_orders/1").to route_to("cart_orders#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/cart_orders/1").to route_to("cart_orders#destroy", id: "1")
    end
  end
end
