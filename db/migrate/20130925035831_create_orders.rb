class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :subject
      t.string :body
      t.integer :fee
      t.string :transaction_id
      t.string :trade_state
      t.string :pay_info
      t.string :state

      t.timestamps
    end
  end
end
