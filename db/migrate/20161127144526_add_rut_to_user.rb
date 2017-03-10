class AddRutToUser < ActiveRecord::Migration
  def change
  	add_column :users, :rut, :string, null: false, unique: true
  end
end
