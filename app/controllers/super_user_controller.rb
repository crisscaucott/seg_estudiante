class SuperUserController < ApplicationController
	include ApplicationHelper
	before_action :isDecano

	def index
		render action: :index, locals: {context: nil}
	end

	def new_estados_desercion
		# estados_desercion = EstadoDesercion.select([:id, :nombre_estado, :notificar]).order(nombre_estado: :asc)
		estados_desercion = EstadoDesercion.select([:id, :nombre_estado, :notificar]).order(:nombre_estado => :asc)
		render action: :index, locals: {partial: 'new_estado_desercion', estado_desercion: EstadoDesercion.new, estados: estados_desercion, context: 'estado'}
	end

	def modify_estados_desercion
		estados_desercion = EstadoDesercion.select([:id, :nombre_estado, :notificar]).order(:nombre_estado => :asc)
		render action: :index, locals: {partial: 'modify_estado_desercion', context: 'estado', estados: estados_desercion}
		
	end

	def create_estado_desercion
		ed_obj = EstadoDesercion.new(estado_desercion_params)

		if ed_obj.valid?
			# Guardar el nuevo estado de desercion a la BD.
			if !ed_obj.getEstadoDesercion
				ed_obj.save
				render json: {msg: "El nuevo de deserción se ha agregado exitosamente.", type: "success", estado_obj: ed_obj}

			else
				render json: {msg: "El estado de deserción ya se encuentra ingresado.", type: "danger"}, status: 422
			end

		else
			# Fallo en las validaciones del objeto de desercion.
	  	render :json => {msg: ed_obj.getFormatErrorMessages, type: "danger"}, status: 422
			
		end

	end

	def update_estado_desercion
		estado_params = estado_desercion_params
		ed_obj = EstadoDesercion.find_by(id: estado_params[:id])

		if !ed_obj.nil?
			if params[:to_delete] == "1"
				# Borrar estado (REVISAR SI HAY QYE VERIFICAR SI HAY ESTUDIANTES CON ESE ESTADO ANTES DE BORRAR).
				ed_obj.destroy!
				estados_desercion = EstadoDesercion.select([:id, :nombre_estado, :notificar]).order(:nombre_estado => :asc)

				render json: {msg: "Estado de deserción actualizado exitosamente.", table: render_to_string(partial: 'estados_desercion_table', formats: [:html], layout: false, locals: {estados: estados_desercion}), type: "success"}

			elsif params[:to_delete] == "0"
				# Actualizar estado.
				ed_obj.nombre_estado = estado_params[:nombre_estado]
				ed_obj.notificar = estado_params[:notificar]

				# Verificar que el nombre nuevo del estado no exista en la BD.
				if !ed_obj.getEstadoDesercion(ed_obj.id)
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
				# Error de opcion.
				render json: {msg: "Ha ocurrido un error con la opción ingresada.", type: 'danger'}, status: 422
			end
		else
			render json: {msg: "Ha ocurrido un problema con encontrar el estado de desercion en el sistema.", type: "danger"}, status: 422
		end
	end

	def new_user
		users_permissions = UserPermission.getPermissions
		render action: :index, locals: {partial: 'new_user', resource: User.new, users_permissions: users_permissions, context: 'usuario'}
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

	def update_user
		users_params = update_user_params
		user_obj = User.find_by(id: users_params[:id])

		if !user_obj.nil?
			users = User.getUsers
			users_permissions = UserPermission.getPermissions

			if params[:to_delete] == "1"
				user_obj.deleted_at = DateTime.now
				user_obj.save

				render json: {msg: "Usuario borrado exitosamente.", type: "success", table: render_to_string(partial: 'usuarios_table', formats: [:html], layout: false, locals: {users: users, users_permissions: users_permissions})}

			elsif params[:row_edited] == "1"
				# Si se encontro el usuario con el id.
				user_obj.assign_attributes(users_params.except(:id, :deleted_at))
				user_obj.deleted_at = nil if users_params[:deleted_at] == "0"

				if user_obj.valid?
					user_obj.save

					# Cumplio con las validaciones.
					render json: {msg: "El usuario ha sido actualizado exitosamente.", type: "success", table: render_to_string(partial: 'usuarios_table', formats: [:html], layout: false, locals: {users: users, users_permissions: users_permissions})}

				else
					# No paso la validaciones.
					render json: {msg: getFormattedAttrObjErrors(user_obj.errors.messages, User), type: "danger"}, status: :bad_request
				end
			else
				# Error de opcion.
				render json: {msg: "Ha ocurrido un error con la opción ingresada.", type: 'danger'}, status: 422
			end
		else
			# No se encontro el usuario en la bd con el id dado.
			render json: {msg: "Hubo en actualizar el usuario."}, status: :bad_request
		end
	end

	def modify_users
		users = User.getUsers
		users_permissions = UserPermission.getPermissions
		render action: :index, locals: {partial: 'modify_usuarios', context: 'usuario', users: users, users_permissions: users_permissions}
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

  def update_user_params
  	params.require(:user).permit(:id, :name, :rut, :last_name, :email, :id_permission, :deleted_at)
  end
end
