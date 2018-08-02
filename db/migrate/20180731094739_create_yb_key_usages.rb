class CreateYbKeyUsages < ActiveRecord::Migration[5.1]
  def change
    create_table :yb_key_usages do |t|
      t.references :yb_key, foreign_key: true
      t.references :admin_user, foreign_key: true

      t.timestamps
    end
  end
end
