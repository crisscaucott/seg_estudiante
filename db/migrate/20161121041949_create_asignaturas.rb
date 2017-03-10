class CreateAsignaturas < ActiveRecord::Migration
  def change
    create_table :asignatura do |t|
    	t.string :nombre, null: false
    	t.string :codigo, null: false
    	t.integer :creditos, null: false
    	t.datetime :fecha_borrado
      t.timestamps null: false
    end
  end
end
