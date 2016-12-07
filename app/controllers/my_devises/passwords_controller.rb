class MyDevises::PasswordsController < Devise::PasswordsController
	include ApplicationHelper

	def new
		super
	end

	def create
		self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      # respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
    
    	# Esto es hermoso!
    	flash[:msg] = "Se ha enviado exitosamente el correo de recuperación de contraseña al email '#{resource.email}'".
    	flash[:alert_type] = 'success'
    	flash.keep(:msg)
    	flash.keep(:alert_type)
    	render js: windowLocation(new_session_path(resource_name))
    else
    	render json: {msg: "No se pudo enviar el correo de recuperación de contraseña con el email ingresado.", type: 'danger'}, status: :bad_request
      # respond_with(resource)
    end
		
	end

	protected
		# The path used after sending reset password instructions
    def after_sending_reset_password_instructions_path_for(resource_name)
      new_session_path(resource_name) if is_navigational_format?
    end

end
