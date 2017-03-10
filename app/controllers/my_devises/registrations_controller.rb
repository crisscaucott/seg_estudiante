class MyDevises::RegistrationsController < Devise::RegistrationsController
	include ApplicationHelper
	private :sign_up_params

	def new
    super
  end

  def create
  	# Crear hash con los datos del usuario.
  	user_params = sign_up_params
  	user_params = user_params.merge(id_permission: UserPermission.getNormalUserId)
    build_resource(user_params)

    if resource.valid?
    	# Campos de usuario validados.
	    if resource.save
	    	# Usuario guardado en BD exitosamente.


	     #  if resource.active_for_authentication?
	     #    set_flash_message :notice, :signed_up if is_navigational_format?
	     #    sign_up(resource_name, resource)
	     #    # return render :json => {:success => true}

	     #  else
	     #    set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
	     #    expire_session_data_after_sign_in!
	     #    # return render :json => {:success => true}
	     #  end

    		# return render :js => windowLocation(root_path)

	    else
	    	# Fallo con guardar en la BD
	      clean_up_passwords resource
	      return render :json => {errors: "Ha ocurrido un error en registrar el usuario."}, status: 422
	    end

    else
    	# Usuario no valido, por sus campos.
	    clean_up_passwords resource
    	return render json: {errors: resource.getFormatErrorMessages}, status: 422
    end
  end

  def sign_up_params
  	params.require(:user).permit(:name, :rut, :last_name, :email, :password, :password_confirmation)
  end

end
