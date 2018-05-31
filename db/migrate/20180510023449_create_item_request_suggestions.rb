class CreateItemRequestSuggestions < ActiveRecord::Migration[5.1]
  def change
    create_table :item_request_suggestions do |t|
      t.references :item_request, foreign_key: true
      t.references :item, foreign_key: true
      t.float :price
      t.string :currency
      t.string :per
      t.string :status

      t.timestamps
    end
  end
end
