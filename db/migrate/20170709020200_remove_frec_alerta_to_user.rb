class RemoveFrecAlertaToUser < ActiveRecord::Migration
  def up
  	remove_foreign_key :users, column: :frec_alerta_id
  	remove_column :users, :frec_alerta_id
  end

  def down
  	add_column :users, :frec_alerta_id, :integer, null: true
    add_foreign_key :users, :frec_alerta, column: :frec_alerta_id
  end
end
