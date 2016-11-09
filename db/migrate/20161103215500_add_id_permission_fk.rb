class AddIdPermissionFk < ActiveRecord::Migration
  def change
		add_foreign_key :users, :user_permissions, column: :id_permission
  end
end
