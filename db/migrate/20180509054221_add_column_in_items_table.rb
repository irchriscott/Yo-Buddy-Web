class AddColumnInItemsTable < ActiveRecord::Migration[5.1]
  def change
  	add_column :items, :is_temp, :boolean
  end
end
