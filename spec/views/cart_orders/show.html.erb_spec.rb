require 'rails_helper'

RSpec.describe "cart_orders/show", type: :view do
  before(:each) do
    @cart_order = assign(:cart_order, CartOrder.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
