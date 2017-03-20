class NombreFormateadoToCarrera < ActiveRecord::Migration
  def change
  	add_column :carrera, :nombre_formateado, :string, null: false
  end
end
