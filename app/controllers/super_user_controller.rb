class SuperUserController < ApplicationController
	include ApplicationHelper
	include MassLoadHelper
	before_action :isDecano
	around_filter :check_params, only: :set_associations_tutores
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
		escuelas = Escuela.getEscuelas

		render action: :index, locals: {partial: 'new_user', resource: User.new, users_permissions: users_permissions, escuelas: escuelas, context: CONTEXTS[:user]}
	end

	def createUser
  	# Crear hash con los datos del usuario.
  	user_params = sign_up_params
  	new_user = User.new(user_params)

    if new_user.valid?
    	
    	# Campos de usuario validados.
	    if new_user.save
	    	# Usuario guardado en BD exitosamente.

	    	return render json: {msg: "Usuario registrado exitosamente.", type: :success}

	    else
	    	# Fallo con guardar en la BD
	      # clean_up_passwords resource
	      return render :json => {msg: "Ha ocurrido un error en registrar el usuario.", type: :danger}, status: 422
	    end
    else
    	# Usuario no valido, por sus campos.
    	return render json: {msg: getFormattedAttrObjErrors(new_user.errors.messages, User), type: :danger}, status: 422
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
		estudiantes = Estudiante.getEstudiantes
		tutores = User.getTutoresUsers
		render action: :index, locals: {partial: 'asociar_tutor_estudiante', context: CONTEXTS[:tutores], tutores: tutores, tutor_usr: User.new, estudiantes: estudiantes}
	end

	def set_associations_tutores
		associations_params = tutores_est_params

		if !associations_params[:id].nil? && !associations_params[:estudiantes].nil?
			tutor_obj = User.find_by(id: associations_params[:id])

			if !tutor_obj.nil?
				# Hash con el detalle de las asociaciones,
				# se guarda las asociaciones nuevas con exito, los estudiantes que ya estaban asociados
				# y el total de estudiantes ingresados en el formulario
				detail = {new: 0, not: 0, total: 0}
				# Obtener un array con los ids de todos los estudiantes asociados al tutor,
				# sirve para evitar asociar un estudiante ya asociado al tutor.
				ids_estudiantes = tutor_obj.estudiante_ids
				detail[:total] = associations_params[:estudiantes][:id].size

				# Recorrer los ids de los estudiantes a asignar al tutor.
				associations_params[:estudiantes][:id].each do |est_id|
					if !ids_estudiantes.include?(est_id.to_i)
						# Si no esta el estudiante en el array, quiere decir que ese estudiante no esta asociado al tutor.

						# Verificar si el id del estudiante esta en la BD (SOLO POR SEGURIDAD).
						est_obj = Estudiante.select(:id).find_by(id: est_id)
						if !est_obj.nil?
							# Asociar el estudiante al tutor (LA MAGIA).
							tutor_obj.estudiantes << est_obj
							detail[:new] += 1
						end
					else
						detail[:not] += 1
						# puts "El tutor id: #{tutor_obj.id} ya tiene asignado al estudiante id: #{est_id}".green
					end
				end

				render json: {msg: render_to_string(partial: 'detalle_asociacion_tutor', formats: [:html], layout: false, locals: {detail: detail, tutor: tutor_obj}), type: :success}
			else
				render json: {msg: "Hubo un problema en encontrar al tutor seleccionado en el sistema.", type: :danger}, status: :bad_request
			end
		else
			render json: {msg: "Debes seleccionar un tutor y estudiantes para poder realizar la asignación.", type: :danger}, status: :bad_request
		end
	end

	def set_desasociations_tutores
		desasociations_params = tutores_est_params

		if !desasociations_params[:id].nil? && !desasociations_params[:estudiantes].nil?
			tutor_obj = User.find_by(id: desasociations_params[:id])

			if !tutor_obj.nil?
				# Hash con el detalle de las desasociaciones,
				# se guarda las desasociaciones nuevas con exito.
				detail = {disassociated: 0, total: desasociations_params[:estudiantes][:id].size, associated: 0}

				# Se recorre todos los estudiantes asignados del tutor...
				tutor_obj.estudiantes.each do |est_obj|
					# Si el id de alguno de ellos esta en el array de ids que se quiere desasociar...
					if desasociations_params[:estudiantes][:id].include?(est_obj.id.to_s)
						# Se borra la asociacion (borra tupla en la tabla intermedia).
						tutor_obj.estudiantes.delete(est_obj)
						detail[:disassociated] += 1
					end
				end

				# Contar cuantos estudiantes asociados le quedan al tutor despues de la desasociacion.
				detail[:associated] = tutor_obj.estudiantes.size

				render json: {
					msg: render_to_string(partial: 'detalle_desasociacion_tutor', formats: [:html], layout: false, locals: {detail: detail, tutor: tutor_obj}),
					estudiantes_list: detail[:associated] != 0 ? render_to_string(partial: 'lista_estudiantes_by_tutor', formats: [:html], layout: false, locals: {estudiantes: tutor_obj.estudiantes}) : nil,
					type: :success
				}

			else
				render json: {msg: "Hubo un problema en encontrar al tutor seleccionado en el sistema.", type: :danger}, status: :bad_request

			end			
		else
			render json: {msg: "Debes seleccionar un tutor y estudiantes para poder realizar la desasociación.", type: :danger}, status: :bad_request
		end
	end

	def ver_asociaciones
		tutores = User.getTutoresUsers
		render action: :index, locals: {partial: 'ver_asociaciones', context: CONTEXTS[:tutores], tutores: tutores, tutor_usr: User.new}
	end

	def get_estudiantes_by_tutor
		tutor_params = get_estudiantes_params

		if !tutor_params[:id].nil?
			tutor_obj = User.find_by(id: tutor_params[:id])

			if !tutor_obj.nil?
				if !tutor_obj.estudiantes.empty?

					render json: {msg: "Estudiantes obtenidos exitosamente.",estudiantes_list: render_to_string(partial: 'lista_estudiantes_by_tutor', formats: [:html], layout: false, locals: {estudiantes: tutor_obj.estudiantes}), type: :success}
				else
					render json: {msg: "El tutor seleccionado <b>no tiene estudiantes asignados.</b>".html_safe, type: :warning}, status: :bad_request				
				end
			else
				render json: {msg: "Hubo un problema en encontrar al tutor seleccionado en el sistema.", type: :danger}, status: :bad_request				
			end

		else
			render json: {msg: "Debe seleccionar un tutor para poder obtener sus estudiantes asociados.", type: :danger}, status: :bad_request
		end
	end

	# --- FIN METODOS TUTORES ---

	private
		def isDecano
			if current_user.user_permission.name != "Decano"
				redirect_to :root, :status => 301, :flash => { msg: 'Usted no tiene los permisos para estar en esta sección.', alert_type: 'warning'}
			end		
		end

		# Esta funcion sirve para verificar que existan datos enviados del formulario del tutor-estudiantes, toma la excepcion y devuelve un json con el error.
		def check_params
			begin
				yield
			rescue ActionController::ParameterMissing => e
				render json: {msg: "Faltan datos.", type: :danger}, status: :bad_request
			rescue StandardError => e
				raise e
			end
		end

		def get_estudiantes_params
			params.require(:users).permit(:id)
		end

		def tutores_est_params
			params.require(:users).permit(:id, estudiantes: [id: []])
		end

		def frec_alerta_params
			params.require(:alerta_config).permit(:frec_alerta_id, :fecha_comienzo)
		end

		def estado_desercion_params
			params.require(:estado_desercion).permit(:id, :nombre_estado, :notificar, :riesgoso)
		end

		def sign_up_params
	  	params.require(:user).permit(:name, :rut, :last_name, :email, :password, :password_confirmation, :id_permission, :escuela_id)
	  end

	  def update_user_params
	  	params.require(:user).permit(:id, :name, :rut, :last_name, :email, :id_permission, :deleted_at)
	  end
	  
end
