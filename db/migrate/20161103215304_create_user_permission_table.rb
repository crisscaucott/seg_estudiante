class CreateUserPermissionTable < ActiveRecord::Migration
  def change
    create_table :user_permissions do |t|
    	t.column :name, :string, null: false
    end
  end
end
