class CreateBorrowMessageImages < ActiveRecord::Migration[5.1]
  def change
    create_table :borrow_message_images do |t|
      t.references :borrow_message, foreign_key: true
      t.string :image

      t.timestamps
    end
  end
end
