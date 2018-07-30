class CreateYbPackages < ActiveRecord::Migration[5.1]
  def change
    create_table :yb_packages do |t|
      t.string :type
      t.integer :items
      t.integer :users
      t.float :price

      t.timestamps
    end
  end
end
