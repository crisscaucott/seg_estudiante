class AddNombreFormateadoToAsignatura < ActiveRecord::Migration
  def change
  	add_column :asignatura, :nombre_formateado, :string, null: false
  end
end
