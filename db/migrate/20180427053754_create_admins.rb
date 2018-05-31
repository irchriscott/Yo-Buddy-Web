class CreateAdmins < ActiveRecord::Migration[5.1]
  def change
    create_table :admins do |t|
      t.string :name
      t.string :username
      t.string :email
      t.string :password_digest
      t.string :image
      t.string :privileges

      t.timestamps
    end
  end
end
