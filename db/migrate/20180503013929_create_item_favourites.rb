class CreateItemFavourites < ActiveRecord::Migration[5.1]
  def change
    create_table :item_favourites do |t|
      t.references :item, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
