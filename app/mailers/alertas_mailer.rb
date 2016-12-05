class AlertasMailer < ApplicationMailer
	default from: "ccaucott@goplaceit.cl"

	def alert_estudiantes(estudiantes, email)
		@estudiantes = estudiantes
  	email = mail from: ENV['username'], to: 'criss.acv@gmail.com', subject: 'this is an email'
	end
end
