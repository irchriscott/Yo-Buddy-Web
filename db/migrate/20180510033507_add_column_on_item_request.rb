class AddColumnOnItemRequest < ActiveRecord::Migration[5.1]
  def change
  	add_column :item_requests, :numbers, :integer
  end
end
