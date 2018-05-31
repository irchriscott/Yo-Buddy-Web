class AddCountOnItemRequest < ActiveRecord::Migration[5.1]
  def change
  	add_column :item_requests, :count, :integer
  end
end
