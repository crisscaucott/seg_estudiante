class AddUserPermissionColumn < ActiveRecord::Migration
  def change
  	add_column :usuario, :id_permiso, :integer, null: false
  end
end
