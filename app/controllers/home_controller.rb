class HomeController < ApplicationController
  def index
    redirect_to orders_path
  end
end
