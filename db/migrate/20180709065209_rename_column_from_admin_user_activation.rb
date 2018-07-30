class RenameColumnFromAdminUserActivation < ActiveRecord::Migration[5.1]
  def change
  	rename_column :admin_user_activations, :type, :key_type
  end
end
