class AddFieldToBorrowItemUser < ActiveRecord::Migration[5.1]
  def change
    add_column :borrow_item_users, :to, :datetime
  end
end
