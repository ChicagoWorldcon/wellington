require 'rails_helper'

RSpec.describe "cart_orders/edit", type: :view do
  before(:each) do
    @cart_order = assign(:cart_order, CartOrder.create!())
  end

  it "renders the edit cart_order form" do
    render

    assert_select "form[action=?][method=?]", cart_order_path(@cart_order), "post" do
    end
  end
end
