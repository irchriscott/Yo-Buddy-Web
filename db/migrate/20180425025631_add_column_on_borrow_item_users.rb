class AddColumnOnBorrowItemUsers < ActiveRecord::Migration[5.1]
  	def change
  		add_column :borrow_item_users, :last_update_user_id, :integer
  	end
end
