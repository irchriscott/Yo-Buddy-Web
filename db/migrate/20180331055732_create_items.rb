class CreateItems < ActiveRecord::Migration[5.1]
  def change
    create_table :items do |t|
      t.string :name
      t.float :price
      t.string :per
      t.string :currency
      t.string :description
      t.string :status
      t.integer :count
      t.boolean :is_available
      t.boolean :is_deleted
      t.boolean :is_temp
      t.references :category, foreign_key: true
      t.references :subcategory, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
