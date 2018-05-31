class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses do |t|
      t.float :longitude
      t.float :latitude
      t.string :address
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
