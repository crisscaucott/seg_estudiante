class CreateLogCargaMasivas < ActiveRecord::Migration
  def change
    create_table :log_carga_masiva do |t|
    	t.integer :usuario_id, null: false
    	t.string :tipo_carga, null: false
      t.timestamps null: false
    end

    add_foreign_key :log_carga_masiva, :users, column: :usuario_id
  end
end
