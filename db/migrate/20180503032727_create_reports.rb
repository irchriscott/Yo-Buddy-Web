class CreateReports < ActiveRecord::Migration[5.1]
  def change
    create_table :reports do |t|
      t.references :user, foreign_key: true
      t.string :ressource
      t.integer :ressource_id
      t.string :about
      t.string :text

      t.timestamps
    end
  end
end
