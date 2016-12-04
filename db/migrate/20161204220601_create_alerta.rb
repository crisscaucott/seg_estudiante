class CreateAlerta < ActiveRecord::Migration
  def change
    create_table :alerta do |t|
    	t.integer :usuario_id, null: false
    	t.string :tipo_alert, null: false
    	t.datetime :fecha_envio, null: false
    	t.string :mensaje, null: false
    	t.string :estado, null: false
      t.timestamps null: false
    end

    add_foreign_key :alerta, :users, column: :usuario_id
  end
end
