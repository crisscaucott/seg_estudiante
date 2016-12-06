class AddFrecAlertaIdToUser < ActiveRecord::Migration
  def change
  	add_column :users, :frec_alerta_id, :integer
  	add_foreign_key :users, :frec_alerta, column: :frec_alerta_id
  end
end
