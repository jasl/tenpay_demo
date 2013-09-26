class OrdersController < ApplicationController
  before_action :set_order, except: [:index, :new, :create]

  def index
    @orders = Order.all
  end

  def show
  end

  def new
    @order = Order.new
  end

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
    # notify may reach earlier than callback
    if JaslTenpay::Sign.verify? params.except(*request.path_parameters.keys) and @order.state == :pending
      @order.update_attributes :transaction_id => params[:transaction_id],
                               :trade_state => params[:trade_state],
                               :pay_info => params[:pay_info],
                               :paid_at => params[:time_end],
                               :state => :paid
    end

    redirect_to @order, notice: 'Order was successfully paid.'
  end

  def notify
    if JaslTenpay::Notify.verify? params.except(*request.path_parameters.keys)
      @order.update_attributes :transaction_id => params[:transaction_id],
                               :trade_state => params[:trade_state],
                               :pay_info => params[:pay_info],
                               :paid_at => params[:time_end],
                               :state => :confirmed
      render text: 'success'
    else
      render text: 'fail'
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:subject, :body, :fee)
  end

  def generate_tenpay_url(options)
    options = {
        :return_url => callback_order_url(@order),
        :notify_url => notify_order_url(@order),
        :spbill_create_ip => request.ip,
    }.merge(options)
    JaslTenpay::Service.create_interactive_mode_url(options)
  end
end
