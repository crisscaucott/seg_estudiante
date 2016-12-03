class AllowNullsEstadoDesercionId < ActiveRecord::Migration
  def change
  	change_column :estudiante, :estado_desercion_id, :integer, null: true
  end
end
