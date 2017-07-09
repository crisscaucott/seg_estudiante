class CreateConfiguracionApps < ActiveRecord::Migration
  def change
    create_table :configuracion_app do |t|
    	t.string :nombre_config, null: false
    	t.json :atributos_config, null: false
    end
  end
end
