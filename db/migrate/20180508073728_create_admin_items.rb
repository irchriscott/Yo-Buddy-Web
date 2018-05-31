class CreateAdminItems < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_items do |t|
      t.references :item, foreign_key: true
      t.integer :borrow_id
      t.string :status
      t.boolean :is_available

      t.timestamps
    end
  end
end
