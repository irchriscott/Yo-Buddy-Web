class CreateAdminUserPaychecks < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_user_paychecks do |t|
      t.references :admin_users, foreign_key: true
      t.float :amount
      t.string :currency
      t.datetime :from_date
      t.datetime :to_date

      t.timestamps
    end
  end
end
