class AddColumnBorrowItemUsers < ActiveRecord::Migration[5.1]
  def change
  	add_column :borrow_item_users, :is_deleted, :boolean
  end
end
