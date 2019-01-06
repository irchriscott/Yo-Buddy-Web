class CreateBorrowItemAdminFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :borrow_item_admin_files do |t|
      t.references :borrow_item_admin, foreign_key: true
      t.string :file
      t.string :extension

      t.timestamps
    end
  end
end
