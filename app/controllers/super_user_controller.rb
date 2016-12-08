class SuperUserController < ApplicationController
	include ApplicationHelper
	include MassLoadHelper
	before_action :isDecano
	CONTEXTS = {
		estado: 'estado',
		user: 'usuario',
		estudiantes: 'estudiantes',
		alertas: 'alertas',
		tutores: 'tutores'
	}

	def index
		render action: :index, locals: {context: nil}
	end

	# --- METODOS ESTADO DE DESERCION ---

	def new_estados_desercion
		# estados_desercion = EstadoDesercion.select([:id, :nombre_estado, :notificar]).order(nombre_estado: :asc)
		estados_desercion = EstadoDesercion.getEstados
		render action: :index, locals: {partial: 'new_estado_desercion', estado_desercion: EstadoDesercion.new, estados: estados_desercion, context: CONTEXTS[:estado]}
	end

	def modify_estados_desercion
		estados_desercion = EstadoDesercion.getEstados
		render action: :index, locals: {partial: 'modify_estado_desercion', context: CONTEXTS[:estado], estados: estados_desercion}
		
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
			# Verificar que el estado no sea fijo.
			if !ed_obj.checkIsEstadoFijo
				if params[:to_delete] == "1"
					# Borrar estado
					if !params[:replace_estado].nil?
						if ed_obj.id != params[:replace_estado]
							replace_ed_obj = EstadoDesercion.find_by(id: params[:replace_estado])
							if !replace_ed_obj.nil?
								# Primero actualizar a todos los estudiantes con el estado de desercion de reemplazo.
								Estudiante.where(estado_desercion_id: ed_obj.id).update_all(estado_desercion_id: replace_ed_obj.id)

								# Despues borrar estado (REVISAR SI HAY QYE VERIFICAR SI HAY ESTUDIANTES CON ESE ESTADO ANTES DE BORRAR).
								ed_obj.destroy!
								estados_desercion = EstadoDesercion.getEstados

								render json: {msg: "Estado de deserción eliminado exitosamente.", table: render_to_string(partial: 'estados_desercion_table', formats: [:html], layout: false, locals: {estados: estados_desercion}), type: "success"}

							else
								render json: {msg: "Ha ocurrido un problema en encontrar el estado de deserción para reasignar a los estudiantes del sistema.", type: "danger"}, status: :bad_request					
							end

						else
							render json: {msg: "El estado de deserción a borrar es el mismo que el estado para la reasignación.", type: "danger"}, status: :bad_request					
						end
					else
						render json: {msg: "Ha ocurrido un problema con el borrado del estado de deserción.", type: "danger"}, status: :bad_request
					end

				elsif params[:row_edited] == "1"
					# Actualizar estado.
					ed_obj.nombre_estado = estado_params[:nombre_estado]
					ed_obj.notificar = estado_params[:notificar]
					ed_obj.riesgoso = estado_params[:riesgoso]

					# Verificar que el nombre nuevo del estado no exista en la BD.
					if !ed_obj.getEstadoDesercion(ed_obj.id)
						if ed_obj.save
							estados_desercion = EstadoDesercion.getEstados

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
				# Es el estado de desercion fijo,
				render json: {msg: "El estado de desercion selecionado no se puede borrar ni modificar.", type: "danger"}, status: :bad_request
			end
		else
			render json: {msg: "Ha ocurrido un problema con encontrar el estado de desercion en el sistema.", type: "danger"}, status: 422
		end
	end

	# --- FIN METODOS ESTADO DE DESERCION ---


	# --- METODOS USUARIO ---

	def new_user
		users_permissions = UserPermission.getPermissions
		render action: :index, locals: {partial: 'new_user', resource: User.new, users_permissions: users_permissions, context: CONTEXTS[:user]}
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
		render action: :index, locals: {partial: 'modify_usuarios', context: CONTEXTS[:user], users: users, users_permissions: users_permissions}
	end

	# --- FIN METODOS USUARIO ---


	# --- METODOS ESTUDIANTES ---

	def subir_estudiantes
		
		render action: :index, locals: {partial: 'subir_estudiantes', context: CONTEXTS[:estudiantes], file: LogCargaMasiva.new}
	end

	def subir_estudiantes_xls
		est_params = subir_estudiante_params
		uploaded_file = uploadFile(est_params[:url_archivo])

		if !uploaded_file[:file_path].nil?
			mass_load_obj = LogCargaMasiva.new(usuario_id: current_user.id, url_archivo: uploaded_file[:file_path])

			res = mass_load_obj.uploadEstudiantes()

			if !res[:error]
				render json: {msg: render_to_string(partial: 'detalle_subida_estudiante', formats: [:html], layout: false, locals: {detail: res[:msg]}), type: "success"}
				
			else
				render json: {msg: res[:msg], type: "danger"}, status: :bad_request
			end
		else
			render json: {msg: "Ha ocurrido un problema en guardar el archivo."}, status: :unprocessable_entity
		end
	end

	# --- FIN METODOS ESTUDIANTES ---


	# --- METODOS ALERTAS ---

	def config_alertas
		render action: :index, locals: {partial: 'config_alertas' ,context: CONTEXTS[:alertas], user: User.new, frecuencia_alertas: FrecAlerta.all.order(dias: :asc)}
	end

	def set_config_alertas
		config_params = frec_alerta_params

		frec_alerta_obj = FrecAlerta.find_by(id: config_params[:frec_alerta_id])
		if !frec_alerta_obj.nil?
			if config_params[:fecha_comienzo].present?

				if frec_alerta_obj.dias != 0
					# Revisar que la fecha de envio calculada (fecha comienza + frecuencia de dias) sea al menos 1 dia mas que el dia de hoy.
					hoydia = DateTime.now.to_date
					fecha_envio = DateTime.parse(config_params[:fecha_comienzo]) + frec_alerta_obj.dias.days

					if (fecha_envio - hoydia).to_i > 0
						# Fecha de envio validada.
						# Setear la frencuencia de alertas de todos los usuarios, menos el usuario actual osea el decano.
						User.setFrecAlertaId(current_user.id, frec_alerta_obj.id)
						users = User.getUsers({except_user_id: current_user.id})

						# Generar las alertas para todos los usuarios.
						Alerta.setAlertaToUsers(users, fecha_envio)

						render json: {msg: "Configuración de alertas hecha exitosamente.", type: "success"}
					else
						# La fecha de envio es menor que la fecha de hoydia
						render json: {msg: "La fecha de envio calculada es menor que hoy dia. Por favor seleciona una fecha de comienzo mas tardía.", type: "warning"}, status: :unprocessable_entity
						
					end

				else
					# Si tiene marcado la opcion de 'desactivado', se borraran todas las alertas pendientes.
					alertas_deleted = Alerta.deleteAlertasPendientes
					render json: {msg: "Configuración de alertas hecha exitosamente. Se han detenido <b>#{alertas_deleted}</b> alertas que ya estaban pendientes.".html_safe, type: "success"}

				end
			else
				render json: {msg: "La fecha de comienzo no está definida.", type: "danger"}, status: :unprocessable_entity
							
			end
		else
			render json: {msg: "Ha ocurrido un error en configurar la frecuencia de alertas a los usuarios.", type: "danger"}, status: :unprocessable_entity
		end
	end

	# --- FIN METODOS ALERTAS ---


	# --- METODOS TUTORES ---

	def asociar_tutores_est_index
		render action: :index, locals: {partial: 'asociar_tutor_estudiante', context: CONTEXTS[:tutores]}
	end

	# --- FIN METODOS TUTORES ---

	private
		def isDecano
			if current_user.user_permission.name != "Decano"
				redirect_to :root, :status => 301, :flash => { msg: 'Usted no tiene los permisos para estar en esta sección.', alert_type: 'warning'}
			end		
		end

		def frec_alerta_params
			params.require(:alerta_config).permit(:frec_alerta_id, :fecha_comienzo)
		end

		def estado_desercion_params
			params.require(:estado_desercion).permit(:id, :nombre_estado, :notificar, :riesgoso)
		end

		def sign_up_params
	  	params.require(:user).permit(:name, :rut, :last_name, :email, :password, :password_confirmation, :id_permission)
	  end

	  def update_user_params
	  	params.require(:user).permit(:id, :name, :rut, :last_name, :email, :id_permission, :deleted_at)
	  end

	  def subir_estudiante_params
	  	params.require(:log_carga_masiva).permit(:url_archivo)
	  end
end
