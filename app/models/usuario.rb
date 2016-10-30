class Usuario < ActiveRecord::Base
	self.table_name = "usuario"
	devise :database_authenticatable, :confirmable, :recoverable, :registerable, :rememberable, :validatable

	# Validaciones
	validates :nombre, :apellido, :email, :encrypted_password, presence: true

	def self.createUser(user_data)
		byebug
		res = {error: false, msg: nil}

		if user_data[:password] == user_data[:password_confirmation]
			# Contrasenas iguales
			user = self.new(nombre: user_data[:nombre], apellido: user_data[:apellido], email: user_data[:email], encrypted_password: user_data[:password])

			if user.valid?
				# Pasaron todas las validaciones de sus campos.
				user.save
				byebug

			else
				# No pasaron todas las validaciones de sus campos.
				puts "No paso las validaciones"
				res[:error] = true
				
			end
			
		else
			# Contrasenas distintas
			puts "Contrasenas distintas"
			res[:error] = true
			
		end

		return res
	end # END self.createUser

end
