class CreateEstilosAprendizajes < ActiveRecord::Migration
  def change
    create_table :estilos_aprendizaje do |t|
    	t.integer :estudiante_id, null: false
    	t.integer :honey_activo
    	t.integer :honey_reflexivo
    	t.integer :honey_teorico
    	t.integer :honey_practico
    	t.integer :vark_visual
    	t.integer :vark_auditivo
    	t.integer :vark_le
    	t.integer :vark_kinestesico
      t.timestamps null: false
    end

    add_foreign_key :estilos_aprendizaje, :estudiante, column: :estudiante_id
  end
end
