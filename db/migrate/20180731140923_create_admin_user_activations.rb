class CreateAdminUserActivations < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_user_activations do |t|
      t.references :admin_user, foreign_key: true
      t.references :yb_key, foreign_key: true
      t.boolean :is_active

      t.timestamps
    end
  end
end
