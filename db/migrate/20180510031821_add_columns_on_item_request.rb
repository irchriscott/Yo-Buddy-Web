class AddColumnsOnItemRequest < ActiveRecord::Migration[5.1]
  def change
  	add_column :item_requests, :min_price, :float
  	add_column :item_requests, :max_price, :float
  	add_column :item_requests, :currency, :string
  end
end
