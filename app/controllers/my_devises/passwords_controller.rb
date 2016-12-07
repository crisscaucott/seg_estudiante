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
    	flash[:msg] = "Se ha enviado exitosamente el correo de recuperación de contraseña al email '#{resource.email}'."
    	flash[:alert_type] = 'success'
    	flash.keep(:msg)
    	flash.keep(:alert_type)
    	render js: windowLocation(new_session_path(resource_name))
    else
    	render json: {msg: "No se pudo enviar el correo de recuperación de contraseña con el email ingresado.", type: 'danger'}, status: :bad_request
      # respond_with(resource)
    end
	end

	def edit
    set_minimum_password_length
		super
	end

	def update
		self.resource = resource_class.reset_password_by_token(resource_params)
		    yield resource if block_given?

		if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      
      if Devise.sign_in_after_reset_password
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message!(:msg, flash_message)
        sign_in(resource_name, resource)
      else
        set_flash_message!(:msg, :updated_not_active)
      end

    	flash[:alert_type] = 'success'
    	flash.keep(:alert_type)

			render :js => windowLocation(after_resetting_password_path_for(resource))
      # respond_with resource, location: after_resetting_password_path_for(resource)
    else
      set_minimum_password_length
      render json: {msg: getFormattedAttrObjErrors(resource.errors.messages, User), type: 'danger'}, status: :bad_request
    end
	end

	protected
		# The path used after sending reset password instructions
    def after_sending_reset_password_instructions_path_for(resource_name)
      new_session_path(resource_name) if is_navigational_format?
    end

    # Check if proper Lockable module methods are present & unlock strategy
    # allows to unlock resource on password reset
    def unlockable?(resource)
      resource.respond_to?(:unlock_access!) &&
        resource.respond_to?(:unlock_strategy_enabled?) &&
        resource.unlock_strategy_enabled?(:email)
    end

end
