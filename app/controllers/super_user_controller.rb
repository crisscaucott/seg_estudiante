class SuperUserController < ApplicationController
	before_action :isDecano


	def index
		
	end

	def new_user
		users_permissions = UserPermission.select([:id, :name]).order(name: :asc)
		render action: :index, locals: {partial: 'new_user', resource: User.new, users_permissions: users_permissions}
	end

	def createUser
  	# Crear hash con los datos del usuario.
  	new_user = User.new(sign_up_params)

    if new_user.valid?
    	# Campos de usuario validados.
	    if new_user.save
	    	# Usuario guardado en BD exitosamente.

	    	return render json: {msg: "Usuario registrado exitosamente."}

	    else
	    	# Fallo con guardar en la BD
	      clean_up_passwords resource
	      return render :json => {errors: "Ha ocurrido un error en registrar el usuario."}, status: 422
	    end

    else
    	# Usuario no valido, por sus campos.
    	return render json: {errors: new_user.getFormatErrorMessages}, status: 422
    end
	end

	def isDecano
		if current_user.user_permission.name != "Decano"
			redirect_to :root, :status => 301, :flash => { msg: 'Usted no tiene los permisos para estar en esta sección.', alert_type: 'warning'}
		end		
	end

	def sign_up_params
  	params.require(:user).permit(:name, :rut, :last_name, :email, :password, :password_confirmation, :id_permission)
  end
end
