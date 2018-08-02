class CreateAdminUserKeypays < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_user_keypays do |t|
      t.references :yb_key, foreign_key: true
      t.references :admin_user, foreign_key: true
      t.float :amount
      t.string :currency

      t.timestamps
    end
  end
end
