class AddDetailColumnToLogCargaMasiva < ActiveRecord::Migration
  def change
  	add_column :log_carga_masiva, :detalle, :json
  end
end
