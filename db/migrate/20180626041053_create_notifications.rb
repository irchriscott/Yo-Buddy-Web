class CreateNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :notifications do |t|
      t.integer :user_from_id
      t.integer :user_to_id
      t.string :ressource
      t.integer :ressource_id
      t.boolean :is_read

      t.timestamps
    end
  end
end
