class AlertasMailer < ApplicationMailer

	def alert_estudiantes(estudiantes, email)
		@estudiantes = estudiantes
  	mail_gun_stat = mail(from: ENV['username'], to: email, subject: 'Alerta de posibles alumnos desertores, por UCEN22')
	end
end
