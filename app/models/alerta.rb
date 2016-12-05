class Alerta < ActiveRecord::Base
	self.table_name = "alerta"
	has_one :user, class_name: "User", foreign_key: "id", primary_key: "usuario_id"

	def self.setAlertaToUsers(users, fecha_envio)
		users.each do |u|
			alerta_obj = self.new(
				usuario_id: u.id,
				tipo_alerta: "email",
				fecha_envio: fecha_envio,
			)
			alerta_obj.save
		end
	end	

end