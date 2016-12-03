class AllowNullsEstadoDesercionId < ActiveRecord::Migration
  def up
  	change_column :estudiante, :estado_desercion_id, :integer, null: true
  	remove_foreign_key :estudiante, column: :estado_desercion_id
  end

  def down
  	change_column :estudiante, :estado_desercion_id, :integer, null: false
    add_foreign_key :estudiante, :estado_desercion, column: :estado_desercion_id
  end
end
