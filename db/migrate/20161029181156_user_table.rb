class UserTable < ActiveRecord::Migration
  def change
  	create_table :usuario do |t|
  		t.column :nombre, :string, null: false
  		t.column :encrypted_password, :string, null: false
  		t.column :email, :string, null: false
  		t.column :apellido, :string, null: false
  		t.timestamps 
  	end
  end
end
