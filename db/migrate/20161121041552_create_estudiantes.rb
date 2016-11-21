class CreateEstudiantes < ActiveRecord::Migration
  def change
    create_table :estudiante do |t|
    	t.string :nombre, null: false
    	t.string :apellido, null: false
    	t.string :rut, null: false
    	t.integer :carrera_id, null: false
    	t.integer :estado_desercion_id, null: false
      t.timestamps null: false
    end
    
    add_foreign_key :estudiante, :carrera, column: :carrera_id
    add_foreign_key :estudiante, :estado_desercion, column: :estado_desercion_id
  end
end
