class AddPaymentToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :payment_type, :integer
  end
end
