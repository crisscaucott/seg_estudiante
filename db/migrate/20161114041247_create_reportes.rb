class CreateReportes < ActiveRecord::Migration
  def change
    create_table :reportes do |t|
    	t.string :nombre_reporte, null: false
    	t.string :tipo_reporte, null: false
    	t.integer :usuario_id, null: false
    	t.boolean :descargado, default: false
      t.timestamps null: false
    end

    add_foreign_key :reportes, :users, column: :usuario_id
  end
end
