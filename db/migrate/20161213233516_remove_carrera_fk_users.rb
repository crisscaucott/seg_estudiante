class RemoveCarreraFkUsers < ActiveRecord::Migration
  def up
  	remove_foreign_key :users, column: :carrera_id
  	remove_column :users, :carrera_id
  end

  def down
  	add_column :users, :carrera_id, :integer, null: true
    add_foreign_key :users, :carrera, column: :carrera_id
  end
end
