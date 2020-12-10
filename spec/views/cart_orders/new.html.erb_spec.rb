require 'rails_helper'

RSpec.describe "cart_orders/new", type: :view do
  before(:each) do
    assign(:cart_order, CartOrder.new())
  end

  it "renders new cart_order form" do
    render

    assert_select "form[action=?][method=?]", cart_orders_path, "post" do
    end
  end
end
