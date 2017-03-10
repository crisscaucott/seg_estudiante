class CreateEstadoDesercions < ActiveRecord::Migration
  def change
    create_table :estado_desercion do |t|
    	t.string :nombre_estado, null: false
    	t.boolean :notificar, default: false
      # t.timestamps null: false
    end
  end
end
