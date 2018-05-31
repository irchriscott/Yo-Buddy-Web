class AddCountInBorrowTable < ActiveRecord::Migration[5.1]
  def change
  	add_column :borrow_item_users, :count, :integer
  end
end
