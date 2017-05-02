class AddForeignsToEstadoDesercionHistorial < ActiveRecord::Migration
  def change
    add_foreign_key :estado_desercion_historial, :estudiante, column: :estudiante_id
    add_foreign_key :estado_desercion_historial, :estado_desercion, column: :estado_desercion_id
    add_foreign_key :estado_desercion_historial, :users, column: :usuario_id
  end
end
