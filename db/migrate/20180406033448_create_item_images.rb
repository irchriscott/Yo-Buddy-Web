class CreateItemImages < ActiveRecord::Migration[5.1]
  def change
    create_table :item_images do |t|
      t.references :item, foreign_key: true
      t.string :image

      t.timestamps
    end
  end
end
