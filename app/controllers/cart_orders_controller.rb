class CartOrdersController < ApplicationController
  before_action :set_cart_order, only: [:show, :edit, :update, :destroy]

  # GET /cart_orders
  # GET /cart_orders.json
  def index
    @cart_orders = CartOrder.all
  end

  # GET /cart_orders/1
  # GET /cart_orders/1.json
  def show
  end

  # GET /cart_orders/new
  def new
    @cart_order = CartOrder.new
  end

  # GET /cart_orders/1/edit
  def edit
  end

  # POST /cart_orders
  # POST /cart_orders.json
  def create
    @cart_order = CartOrder.new(cart_order_params)

    respond_to do |format|
      if @cart_order.save
        format.html { redirect_to @cart_order, notice: 'Cart order was successfully created.' }
        format.json { render :show, status: :created, location: @cart_order }
      else
        format.html { render :new }
        format.json { render json: @cart_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cart_orders/1
  # PATCH/PUT /cart_orders/1.json
  def update
    respond_to do |format|
      if @cart_order.update(cart_order_params)
        format.html { redirect_to @cart_order, notice: 'Cart order was successfully updated.' }
        format.json { render :show, status: :ok, location: @cart_order }
      else
        format.html { render :edit }
        format.json { render json: @cart_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cart_orders/1
  # DELETE /cart_orders/1.json
  def destroy
    @cart_order.destroy
    respond_to do |format|
      format.html { redirect_to cart_orders_url, notice: 'Cart order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cart_order
      @cart_order = CartOrder.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cart_order_params
      params.fetch(:cart_order, {})
    end
end
