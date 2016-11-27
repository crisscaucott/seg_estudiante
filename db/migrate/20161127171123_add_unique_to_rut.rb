class AddUniqueToRut < ActiveRecord::Migration
  def change
  	remove_index :users, column: :email, name: 'index_users_on_email'
  	add_index :users, :rut, unique: true
  end
end
