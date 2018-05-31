class CreateBorrowItemFollowUps < ActiveRecord::Migration[5.1]
  def change
    create_table :borrow_item_follow_ups do |t|
      t.references :borrow_item_user, foreign_key: true
      t.references :admin, foreign_key: true
      t.string :about
      t.string :message

      t.timestamps
    end
  end
end
