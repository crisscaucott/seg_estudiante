class CreateCarreras < ActiveRecord::Migration
  def change
    create_table :carreras do |t|
    	t.integer :duracion_formal, null: false
    	t.string :nombre, null: false
    	t.string :codigo, null: false
    	t.datetime :fecha_eliminacion
      t.timestamps null: false
    end
  end
end
