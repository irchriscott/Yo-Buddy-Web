class CreateAdminUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_users do |t|
      t.references :user, foreign_key: true
      t.string :email
      t.string :password_digest
      t.string :privileges
      t.string :image

      t.timestamps
    end
  end
end
