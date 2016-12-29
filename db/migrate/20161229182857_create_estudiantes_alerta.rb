class CreateEstudiantesAlerta < ActiveRecord::Migration
  def change
    create_table :estudiantes_alerta do |t|
    	t.integer :alerta_id, null: false
    	t.integer :estudiante_id, null: false
      t.timestamps null: false
    end
  end
end
