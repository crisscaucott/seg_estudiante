class SuperUserController < ApplicationController
	before_action :isDecano


	def index
		
	end

	def estados_desercion_index
		# estados_desercion = EstadoDesercion.select([:id, :nombre_estado, :notificar]).order(nombre_estado: :asc)
		estados_desercion = EstadoDesercion.select([:id, :nombre_estado, :notificar]).order(:nombre_estado => :asc)
		render action: :index, locals: {partial: 'estados_desercion_index', estado_desercion: EstadoDesercion.new, estados: estados_desercion}
	end

	def new_estado_desercion
		ed_obj = EstadoDesercion.new(estado_desercion_params)

		if ed_obj.valid?
			# Guardar el nuevo estado de desercion a la BD.
			if !ed_obj.getEstadoDesercion
				ed_obj.save
				render json: {msg: "El nuevo de deserción se ha agregado exitosamente.", estado_obj: ed_obj}

			else
				render json: {errors: "El estado de deserción ya se encuentra ingresado."}, status: 422
			end

		else
			# Fallo en las validaciones del objeto de desercion.
	  	render :json => {errors: ed_obj.getFormatErrorMessages}, status: 422
			
		end

	end

	def update_estado_desercion
		estado_params = estado_desercion_params
		ed_obj = EstadoDesercion.find_by(id: estado_params[:id])

		if !ed_obj.nil?
			ed_obj.nombre_estado = estado_params[:nombre_estado]
			ed_obj.notificar = estado_params[:notificar]

			# Verificar que el nombre nuevo del estado no exista en la BD.
			if !ed_obj.getEstadoDesercion
				if ed_obj.save
					estados_desercion = EstadoDesercion.select([:id, :nombre_estado, :notificar]).order(:nombre_estado => :asc)

					render json: {msg: "Estado de deserción actualizado exitosamente.", table: render_to_string(partial: 'estados_desercion_table', formats: [:html], layout: false, locals: {estados: estados_desercion}), type: "success", estado_obj: ed_obj}

				else
					render json: {msg: ed_obj.getFormatErrorMessages, type: 'danger'}, status: 422
				end
			else
				render json: {msg: "El estado de deserción ya se encuentra ingresado.", type: 'danger'}, status: 422
			end
		else
			render json: {msg: "Ha ocurrido un problema con encontrar el estado de desercion en el sistema.", type: "danger"}, status: 422
		end
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

	def estado_desercion_params
		params.require(:estado_desercion).permit(:id, :nombre_estado, :notificar)
	end

	def sign_up_params
  	params.require(:user).permit(:name, :rut, :last_name, :email, :password, :password_confirmation, :id_permission)
  end
end
