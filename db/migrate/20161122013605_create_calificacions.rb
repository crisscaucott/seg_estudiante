class CreateCalificacions < ActiveRecord::Migration
  def change
    create_table :calificacion do |t|
    	t.integer :estudiante_id, null: false
    	t.integer :asignatura_id, null: false
    	t.decimal :valor_calificacion, precision: 5, scale: 2, null: false
    	t.string :nombre_calificacion, null: false
    	t.integer :ponderacion, null: false
    	t.datetime :periodo_academico, null: false
      t.timestamps null: false
    end
    
    add_foreign_key :calificacion, :estudiante, column: :estudiante_id
    add_foreign_key :calificacion, :asignatura, column: :asignatura_id
  end
end
