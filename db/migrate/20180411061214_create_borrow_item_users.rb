class CreateBorrowItemUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :borrow_item_users do |t|
      t.references :item, foreign_key: true
      t.references :user, foreign_key: true
      t.references :admin, foreign_key: true
      t.float :price
      t.string :currency
      t.string :per
      t.string :conditions
      t.string :reasons
      t.string :status
      t.integer :numbers
      t.integer :count
      t.boolean :is_deleted
      t.datetime :from_date
      t.datetime :to_date
      t.integer :last_update_user_id
      t.string :uuid

      t.timestamps
    end
  end
end
