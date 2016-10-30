class Usuario < ActiveRecord::Base
	devise :database_authenticatable, :confirmable, :recoverable, :registerable, :rememberable, :validatable

	self.table_name = "usuario"
end
