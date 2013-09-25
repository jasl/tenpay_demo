class Order < ActiveRecord::Base
  before_create do
    self.state = 'pending'
    self.trade_no = SecureRandom.uuid.gsub '-', ''
  end
end
