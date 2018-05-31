class ModifyBorrowMessages < ActiveRecord::Migration[5.1]
  def change
  	remove_column :borrow_messages, :images_id
  	add_column :borrow_messages, :has_images, :boolean
  end
end
