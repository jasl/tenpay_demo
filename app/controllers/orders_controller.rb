class OrdersController < ApplicationController
  before_action :set_order

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render action: 'show', status: :created, location: @order }
      else
        format.html { render action: 'new' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url }
      format.json { head :no_content }
    end
  end

  def pay
    generate_tenpay_url :subject => @order.subject,
                        :body => @order.body,
                        :total_fee => @order.fee,
                        :out_trade_no => @order.id
  end

  def notify
    logger.info params
    @order.update_attributes :transaction_id => params[:transaction_id],
                             :trade_state => params[:trade_state],
                             :pay_info => params[:pay_info]
  end

  def callback
    logger.info params
    render text: 'success'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(:subject, :order, :fee, :state)
  end

  def generate_tenpay_url(options)
    options = {
        :return_url => tenpay_callback_url,
        :notify_url => tenpay_notify_url,
        :spbill_create_ip => request.ip,
    }.merge(options)
    Tenpay::Service.create_interactive_mode_url(options)
  end
end