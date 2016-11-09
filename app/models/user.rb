class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :user_permission
  validates :name, :last_name, presence: true

  def getFormatErrorMessages
  	error_str = ''
  	self.errors.messages.each do |field, error|
  		case field
  			when :email
  				error_str += "Email: " + error.join(',') + "<br>"
  			
  			when :name
  				error_str += "Nombre: " + error.join(',') + "<br>"

  			when :last_name
  				error_str += "Apellido: " + error.join(',') + "<br>"
  			
  			when :password
  				error_str += "Contraseña: " + error.join(',') + "<br>"
  		end
  	end

  	return error_str.html_safe
  end
end
