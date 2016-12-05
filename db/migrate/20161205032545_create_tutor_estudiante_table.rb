class CreateTutorEstudianteTable < ActiveRecord::Migration
  def change
    create_table :tutor_estudiante do |t|
    	t.integer :usuario_id
    	t.integer :estudiante_id
    end
  end
end
