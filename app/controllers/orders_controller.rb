class OrdersController < ApplicationController
  before_action :set_order, except: [:index, :new, :create]

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
    url = generate_tenpay_url :subject => @order.subject,
                              :body => @order.body,
                              :total_fee => @order.fee,
                              :out_trade_no => @order.trade_no
    redirect_to url
  end

  def callback
    logger.info '========'
    logger.info params
    logger.info '========'

    if Tenpay::Sign.verify? params
      @order.update_attributes :transaction_id => params[:transaction_id],
                               :trade_state => params[:trade_state],
                               :pay_info => params[:pay_info],
                               :paid_at => params[:time_end],
                               :state => :paid
    end

    redirect_to @order
  end

  def notify
    logger.info '========'
    logger.info params
    logger.info '========'

    if Tenpay::Notify.verify? params
      @order.update_attributes :state => :confirmed
      render text: 'success'
    else
      render text: 'fail'
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(:subject, :body, :fee)
  end

  def generate_tenpay_url(options)
    options = {
        :return_url => callback_order_url(@order),
        :notify_url => notify_order_url(@order),
        :spbill_create_ip => request.ip,
    }.merge(options)
    Tenpay::Service.create_interactive_mode_url(options)
  end
end
