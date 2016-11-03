class AddUserPermissionField < ActiveRecord::Migration
  def change
  	add_column :users, :id_permission, :integer, null: false
  end
end
