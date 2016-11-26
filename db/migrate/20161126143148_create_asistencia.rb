class CreateAsistencia < ActiveRecord::Migration
  def change
    create_table :asistencia do |t|
    	t.integer :asignatura_id, null: false
    	t.integer :estudiante_id, null: false
    	t.datetime :fecha_asistida, null: false
    	t.string :valor_asistencia
      t.timestamps null: false
    end

    add_foreign_key :asistencia, :asignatura, column: :asignatura_id
    add_foreign_key :asistencia, :estudiante, column: :estudiante_id
  end
end
