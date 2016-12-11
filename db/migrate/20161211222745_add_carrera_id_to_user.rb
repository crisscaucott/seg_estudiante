class AddCarreraIdToUser < ActiveRecord::Migration
  def change
  	add_column :users, :carrera_id, :integer, null: true
    add_foreign_key :users, :carrera, column: :carrera_id
  end
end
