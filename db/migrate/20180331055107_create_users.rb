class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :username
      t.string :email
      t.string :password_digest
      t.string :country
      t.string :town
      t.string :number
      t.string :image
      t.string :gender
      t.string :token
      t.boolean :is_authenticated
      t.boolean :is_private
      t.boolean :is_blocked

      t.timestamps
    end
  end
end
