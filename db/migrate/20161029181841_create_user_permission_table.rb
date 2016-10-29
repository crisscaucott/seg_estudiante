class CreateUserPermissionTable < ActiveRecord::Migration
  def change
    create_table :permisos_usuario do |t|
    	t.column :nombre, :string, null: false
    end
  end
end
