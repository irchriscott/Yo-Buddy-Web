class AddImageToMessages < ActiveRecord::Migration[5.1]
  def change
  	add_column :borrow_messages, :images_id, :integer
  end
end
