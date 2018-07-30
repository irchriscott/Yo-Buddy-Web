class CreateAdminUserActivations < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_user_activations do |t|
      t.references :admin_user, foreign_key: true
      t.string :key
      t.string :key_type
      t.integer :max_items
      t.integer :max_users
      t.datetime :activated_date
      t.datetime :expary_date
      t.boolean :is_active

      t.timestamps
    end
  end
end
