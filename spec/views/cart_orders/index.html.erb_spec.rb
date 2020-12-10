require 'rails_helper'

RSpec.describe "cart_orders/index", type: :view do
  before(:each) do
    assign(:cart_orders, [
      CartOrder.create!(),
      CartOrder.create!()
    ])
  end

  it "renders a list of cart_orders" do
    render
  end
end
