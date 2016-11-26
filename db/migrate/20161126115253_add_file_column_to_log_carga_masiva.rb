class AddFileColumnToLogCargaMasiva < ActiveRecord::Migration
  def change
  	add_column :log_carga_masiva, :url_archivo, :string, null: false
  end
end
