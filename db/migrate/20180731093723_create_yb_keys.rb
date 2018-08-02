class CreateYbKeys < ActiveRecord::Migration[5.1]
  def change
    create_table :yb_keys do |t|
      t.references :yb_package, foreign_key: true
      t.string :key
      t.boolean :is_active
      t.integer :duration
      t.string :duration_type
      t.datetime :activated_date
      t.integer :remaining
      t.string :status

      t.timestamps
    end
  end
end
