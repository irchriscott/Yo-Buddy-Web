class RenameColumnsBorrowItemUsers < ActiveRecord::Migration[5.1]
  def change
  	rename_column :borrow_item_users, :from, :from_date
  	rename_column :borrow_item_users, :to, :to_date
  end
end
