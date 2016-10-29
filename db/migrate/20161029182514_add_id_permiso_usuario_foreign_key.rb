class AddIdPermisoUsuarioForeignKey < ActiveRecord::Migration
  def change
	add_foreign_key :usuario, :permisos_usuario, column: :id_permiso	
  end
end
