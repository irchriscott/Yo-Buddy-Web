class CreateResetPasswords < ActiveRecord::Migration[5.1]
  def change
    create_table :reset_passwords do |t|
      t.string :resource
      t.integer :resource_id
      t.string :email
      t.string :token
      t.datetime :expiry_date
      t.boolean :is_active
      t.integer :count

      t.timestamps
    end
  end
end
