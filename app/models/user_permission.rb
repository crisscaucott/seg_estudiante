class UserPermission < ActiveRecord::Base
  self.table_name = 'user_permissions'
  has_many :user, class_name: "User"

  # Retorna el id del tipo de usuario Administrador
  def self.getAdminId
  	return self.select(:id).find_by_name("Administrador").id
  end

  # Retorna el id del tipo de usuario Normal
  def self.getNormalUserId
  	return self.select(:id).find_by_name("Usuario normal").id
  end
end
