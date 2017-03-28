class CreateAsistenciaStateTable < ActiveRecord::Migration
  def change
    create_table :estados_asistencia do |t|
    	t.string :nombre_estado, null: false
    	t.string :estado_corto, null: false
    end
  end
end
