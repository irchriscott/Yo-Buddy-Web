class CreateItemRequestImages < ActiveRecord::Migration[5.1]
  def change
    create_table :item_request_images do |t|
      t.references :item_request, foreign_key: true
      t.string :image

      t.timestamps
    end
  end
end
