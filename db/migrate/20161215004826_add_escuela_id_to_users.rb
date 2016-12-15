class AddEscuelaIdToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :escuela_id, :integer, null: true
  	add_foreign_key :users, :escuela, column: :escuela_id
  end
end
