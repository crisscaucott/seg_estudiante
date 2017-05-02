class CreateEstadoDesercionHistorials < ActiveRecord::Migration
  def change
    create_table :estado_desercion_historial do |t|
    	t.integer :estudiante_id, null: false
    	t.integer :estado_desercion_id, null: false
    	t.integer :usuario_id, null: false
      t.timestamps null: false
    end
  end
end
