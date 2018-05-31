class CreateListBorrowItems < ActiveRecord::Migration[5.1]
  def change
    create_table :list_borrow_items do |t|
      t.references :borrow_item_user, foreign_key: true
      t.string :name
      t.string :description
      t.string :state
      t.boolean :is_returned

      t.timestamps
    end
  end
end
