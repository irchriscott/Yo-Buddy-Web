class CreateListBorrowItemFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :list_borrow_item_files do |t|
      t.references :list_borrow_item, foreign_key: true
      t.string :file
      t.string :extension

      t.timestamps
    end
  end
end
