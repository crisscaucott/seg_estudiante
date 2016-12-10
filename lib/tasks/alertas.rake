namespace :alertas do

	desc "Task description"
	task :fill_frec_alertas => :environment do
		ActiveRecord::Base.connection.execute("TRUNCATE #{FrecAlerta.table_name} RESTART IDENTITY")

		frec_alertas = [
			{dias: 7, mensaje: "1 semana"},
			{dias: 15, mensaje: "Quincenal"},
			{dias: 30, mensaje: "1 mes"},
			{dias: 0, mensaje: "Desactivado"},
		]

		frec_alertas.each do |fa|
			FrecAlerta.new(fa).save
		end
	end

	desc "Se envia las alertas via email a cada usuario de los alumnos que sean potencialmente desertores."
	task :enviar_alertas => :environment do
		ActiveRecord::Base.logger = Logger.new(STDOUT)
		hoydia = DateTime.now.to_date
		alertas_pendientes = Alerta.where(estado: "Pendiente").where(tipo_alerta: "email").where("DATE(fecha_envio) = ?", hoydia)

		if alertas_pendientes.present?
			# Hay alertas pendientes que enviar para hoydia
			alertas_pendientes.each do |ap|
				if !ap.user.estudiantes.empty?
					# Tiene estudiantes asignados al usuario (tutor).
					estudiantes_notif = []
					# Se revisa cual de todos los estudiantes tiene un estado de desercion que se tenga que notificar.
					ap.user.estudiantes.each do |est|
						estudiantes_notif << est if est.estado_desercion.notificar
					end

					if estudiantes_notif.size != 0
						begin
							# Aqui esta el array de estudiantes que deben salir en el mail.
							AlertasMailer.alert_estudiantes(estudiantes_notif, ap.user.email).deliver
							ap.estado = "Enviado"
							ap.save

							puts "Email enviado con exito a usuario id: #{ap.user.id}"
							
						rescue StandardError => e
							# Si falla el envio del mail, se marca como fallido la alerta.
							ap.estado = "Fallido"
							ap.save
						end
					else
						# El tutor no tiene estudiantes asignados que deban ser incluidos en el email.
						# Se setea la alerta como no enviado ya que no hay estudiantes.
						ap.estado = "No enviado"
						ap.save
					end # END estudiantes_notif.size
				end # END ap.user.estudiantes.empty?
			end # END alertas_pendientes.each
		else
			puts "No hay alertas pendientes que enviar."
		end # END alertas_pendientes.present?
	end
end