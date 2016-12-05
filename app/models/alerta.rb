class Alerta < ActiveRecord::Base
	self.table_name = "alerta"
	has_one :user, class_name: "User", foreign_key: "id", primary_key: "usuario_id"

	def self.setAlertaToUsers(users, fecha_envio)
		users.each do |u|
			# Consultar si existe la alerta pendiente para el usuario con id = u.id
			alerta_obj = self.where(estado: "Pendiente").where(usuario_id: u.id).where(tipo_alerta: 'email').first

			if alerta_obj.nil?
				# No existe alerta pendiente para tal usuario
				alerta_obj = self.new(
					usuario_id: u.id,
					tipo_alerta: "email",
					fecha_envio: fecha_envio,
				)

				alerta_obj.save
			else
				# Si ya habia una alerta pendiente, solo se actualiza su fecha de envio.
				alerta_obj.fecha_envio = fecha_envio
				alerta_obj.save
			end
		end
	end	

end