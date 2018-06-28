class CreateItemRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :item_requests do |t|
      t.references :user, foreign_key: true
      t.references :category, foreign_key: true
      t.references :subcategory, foreign_key: true
      t.string :title
      t.string :description
      t.datetime :from_date
      t.datetime :to_date
      t.float :min_price
      t.float :max_price
      t.string :currency
      t.string :per
      t.integer :numbers
      t.integer :count
      t.string :status
      t.boolean :is_deleted
      t.string :uuid

      t.timestamps
    end
  end
end
