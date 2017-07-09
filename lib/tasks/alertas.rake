namespace :alertas do

	desc "Task description"
	task :fill_frec_alertas => :environment do
		ActiveRecord::Base.connection.execute("TRUNCATE #{FrecAlerta.table_name} CASCADE")

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
		config_alertas = ConfiguracionApp.getAlertaConfig
		hoydia = DateTime.now.to_date
		# Setear la fecha donde se llamo esta task (ayuda a revisar si el cron esta funcionando).
		config_alertas.atributos_config["last_task_call"] = hoydia

		# Verificar que la fecha de envio exista.
		if !config_alertas.atributos_config["prox_envio"].nil?
			config_alertas.atributos_config["last_error"] = nil

			# Se verifica que la fecha de envio de la alerta sea hoy dia.
			if config_alertas.atributos_config["prox_envio"].to_date == hoydia
				# Se obtienen todos los usuarios que no sean decano (directores, tutores y usuarios normales).
				users = User.getNoDecanoUsers
				errors = []

				users.each do |user|
					ap = Alerta.new(
						usuario_id: user.id,
						tipo_alerta: 'email',
						fecha_envio: hoydia,
						estado: 'Enviado',
						)
					estudiantes = Estudiante.getEstudiantesByUserType(user)

					if (estudiantes != false && estudiantes.present?)
						# Tiene estudiantes asignados al usuario (tutor).
						estudiantes_notif = []
						# Se revisa cual de todos los estudiantes tiene un estado de desercion que se tenga que notificar.
						estudiantes.each do |est|
							estudiantes_notif << est if est.estado_desercion.notificar
						end

						if estudiantes_notif.size != 0
							begin
								# Aqui esta el array de estudiantes que deben salir en el mail.
								AlertasMailer.alert_estudiantes(estudiantes_notif, user.email).deliver
								ap.save

								puts "Email enviado con exito a usuario id: #{user.id}"

								# Agregar los estudiantes enviados a la tabla 'estudiantes_alerta'
								estudiantes_notif.each do |en|
									estudiante_alerta = EstudiantesAlerta.new(
										alerta_id: ap.id,
										estudiante_id: en.id
									)
									ap.estudiantes << estudiante_alerta
								end

							rescue StandardError => e
								# Si falla el envio del mail, se marca como fallido la alerta.
								ap.estado = "Fallido"
								ap.save

								errors << "user id: #{user.id} -> #{e.to_s}"
							end
						else
							# El tutor no tiene estudiantes asignados que deban ser incluidos en el email.
							ap.mensaje = "No hay estudiantes que deban aparecer en el email."
							ap.save

						end # END estudiantes_notif.size

					else
						# El usuario (director o tutor) no tiene estudiantes designados.
						ap.mensaje = "El usuario no tiene estudiantes asignados."
						ap.save

					end
				end # END users.each

				# Se vuelve a calcular la proxima fecha de envio de alertas en base a la opcion definida de frecuencia de alertas.
				frec_alerta_obj = FrecAlerta.find_by(id: config_alertas.atributos_config["frec_alerta_id"])
				config_alertas.atributos_config["prox_envio"] = DateTime.parse(config_alertas.atributos_config["prox_envio"]) + frec_alerta_obj.dias.days
				
				if errors.size != 0
					config_alertas.atributos_config["last_error"] = errors.join(" | ")
				else
					config_alertas.atributos_config["last_error"] = nil
				end

			else
				# La alerta no era para hoy dia...
			end
		else
			# Fecha de envio nulo, posiblemente se ha desactivado el envio de alertas.
			config_alertas.atributos_config["last_error"] = "Fecha de envio sin definir."
		end

		config_alertas.save
	end
end
