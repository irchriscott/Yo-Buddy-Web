class CreateBorrowItemAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :borrow_item_accounts do |t|
      t.references :borrow_item_users, foreign_key: true
      t.float :amount
      t.float :penalties
      t.string :currency

      t.timestamps
    end
  end
end
