class CreateBorrowMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :borrow_messages do |t|
      t.references :borrow_item_user, foreign_key: true
      t.integer :sender_id
      t.integer :receiver_id
      t.string :message
      t.boolean :has_images
      t.string :status
      t.boolean :is_deleted
      t.integer :deleted_by

      t.timestamps
    end
  end
end
