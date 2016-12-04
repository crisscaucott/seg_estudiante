class AddFrecAlertaToUser < ActiveRecord::Migration
  def change
  	add_column :users, :frecuencia_alertas, :integer
  end
end
