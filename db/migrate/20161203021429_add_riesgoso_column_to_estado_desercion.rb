class AddRiesgosoColumnToEstadoDesercion < ActiveRecord::Migration
  def change
  	add_column :estado_desercion, :riesgoso, :boolean, null: false, default: false
  end
end
