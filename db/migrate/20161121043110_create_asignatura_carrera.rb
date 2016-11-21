class CreateAsignaturaCarrera < ActiveRecord::Migration
  def change
    create_table :asignatura_carrera do |t|
    	t.integer :carrera_id
    	t.integer :asignatura_id
    end
  end
end
