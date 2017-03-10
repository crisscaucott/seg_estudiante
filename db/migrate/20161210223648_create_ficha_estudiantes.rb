class CreateFichaEstudiantes < ActiveRecord::Migration
  def change
    create_table :ficha_estudiante do |t|
    	t.integer :estudiante_id, null: false
    	t.integer :tutor_id, null: false
    	t.integer :estado_desercion_id, null: false
    	t.integer :motivo_desercion_id
    	t.integer :destino_id
    	t.datetime :fecha_registro, null: false
    	t.text :comentario
      t.timestamps null: false
    end

    add_foreign_key :ficha_estudiante, :estudiante, column: :estudiante_id
    add_foreign_key :ficha_estudiante, :users, column: :tutor_id
    add_foreign_key :ficha_estudiante, :estado_desercion, column: :estado_desercion_id

  end

end
