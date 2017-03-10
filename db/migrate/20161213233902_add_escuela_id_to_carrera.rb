class AddEscuelaIdToCarrera < ActiveRecord::Migration
  def change
  	add_column :carrera, :escuela_id, :integer, null: false
  	add_foreign_key :carrera, :escuela, column: :escuela_id
  end
end
