class AddEstadoAsistencia < ActiveRecord::Migration
  def change
  	add_column :asistencia, :estado_asistencia_id, :integer, null: false
  	add_foreign_key :asistencia, :estados_asistencia, column: :estado_asistencia_id
  end
end
