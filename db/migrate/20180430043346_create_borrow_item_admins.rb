class CreateBorrowItemAdmins < ActiveRecord::Migration[5.1]
  def change
    create_table :borrow_item_admins do |t|
      t.references :borrow_item_user, foreign_key: true
      t.references :admin, foreign_key: true
      t.string :status
      t.string :state
      t.string :comment

      t.timestamps
    end
  end
end
