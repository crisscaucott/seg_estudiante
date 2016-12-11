class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, authentication_keys: [:login]

  belongs_to :user_permission, class_name: "UserPermission", foreign_key: "id_permission"
  belongs_to :frec_alerta, class_name: "FrecAlerta", foreign_key: "frec_alerta_id"
  belongs_to :carrera, class_name: "Carrera", foreign_key: "carrera_id"
  has_many :alertas, class_name: "Alerta", foreign_key: "usuario_id"
  has_and_belongs_to_many :estudiantes, class_name: "Estudiante", foreign_key: "usuario_id", join_table: "tutor_estudiante"

  validates :name, :last_name, :email, presence: true
  validates_format_of :email, with: email_regexp
  validates_presence_of :rut
  validates_uniqueness_of :rut
  validates_with RUTValidator # Valida el rut a traves de la clase RUTValidator
  attr_accessor :login

  def getFormatErrorMessages
  	error_str = ''
  	self.errors.messages.each do |field, error|
  		case field
  			when :email
  				error_str += "<b>Email:</b> " + error.join(',') + "<br>"
  			
  			when :name
  				error_str += "<b>Nombre:</b> " + error.join(',') + "<br>"

  			when :last_name
  				error_str += "<b>Apellido:</b> " + error.join(',') + "<br>"
  			
  			when :password
  				error_str += "<b>Contraseña:</b> " + error.join(',') + "<br>"

        when :rut
          error_str += "<b>Rut:</b> " + error.join(',') + "<br>"
          
  		end
  	end

  	return error_str.html_safe
  end

  # Para saltar la validacion por mail unico.
  def email_required?
    false
  end

  def email_changed?
    false
  end

  def self.setFrecAlertaId(except_user_id, frec_alerta_id)
    self.where.not(id: except_user_id).update_all(frec_alerta_id: frec_alerta_id)
  end

  def self.getUsers(filters = {})
    users = self.select([:id, :name, :rut, :last_name, :email, :id_permission, :deleted_at]).order(name: :asc)

    if !filters[:except_user_id].nil?
      users = users.where.not(id: filters[:except_user_id])
    end

    users = users.where.not(deleted_at: nil) if !filters[:deleted_at].nil?
    return users
  end

  def self.getTutoresUsers
    return self.includes(:user_permission).joins(:user_permission).merge(UserPermission.where(name: 'Tutor'))
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_hash).where(["rut = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:rut)
      conditions[:rut] = formatRut(conditions[:rut])
      where(conditions.to_hash).first
    end
  end

  def self.formatRut(rut)
    return rut.gsub(/(\.|\-)/, '')
  end

  # Sobreescribir metodo de asignar el rut al objeto user,
  # para quitar sus puntos y guiones
  def rut=(new_rut)
    self[:rut] = new_rut.gsub(/(\.|\-)/, '').strip
  end
end
