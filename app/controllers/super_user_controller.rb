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
		tutores: 'tutores',
		carreras: 'carreras'
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
				render json: {msg: "El nuevo estado de deserción se ha agregado exitosamente.", type: "success", estado_obj: ed_obj}

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
			render json: {msg: "Hubo un error en encontrar el usuario en el sistema."}, status: :bad_request
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
						users = User.getTutoresAndDirectores()

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


	# --- METODOS CARRERAS ---
	def new_carrera
		render action: :index, locals: {partial: 'new_carrera', context: CONTEXTS[:carreras], escuelas: Escuela.getEscuelas}
	end

	def upload_carrera
		upload_params = new_carrera_params

		if upload_params[:escuela].present?
			escuela_obj = Escuela.select(:id).find_by(id: upload_params[:escuela])

			if !escuela_obj.nil?
				uploaded_file = uploadFile(upload_params[:file])

				if !uploaded_file[:file_path].nil?
					# Subir excel con la carrera y las asignaturas.
					mass_load_obj = LogCargaMasiva.new(usuario_id: current_user.id, url_archivo: uploaded_file[:file_path])

					res = mass_load_obj.uploadCarreraAsignaturas(escuela_obj.id)

					if !res[:error]
						render json: {msg: render_to_string(partial: 'detalle_subida_carrera', formats: [:html], layout: false, locals: {detail: res[:msg]}), type: "success"}
						
					else
						render json: {msg: res[:msg], type: :danger}, status: :bad_request
					end

				else
					# Problema con guardar el fichero
					render json: {msg: "Ha ocurrido un problema en subir el archivo excel."}, status: :unprocessable_entity
				end

			else
				render json: {msg: "Ha ocurrido un problema en encontrar la escuela seleccionada."}, status: :unprocessable_entity
			end
		else
			render json: {msg: "Debe seleccionar una escuela para poder subir la carrera y las asignaturas.", type: :warning}, status: :unprocessable_entity
		end
	end

	def gestion_carreras
		render action: :index, locals: {partial: 'gestion_carreras', context: CONTEXTS[:carreras], escuelas: Escuela.getEscuelas, carreras: []}
	end

	def get_carreras_by_escuela
		escuela_params = carrera_by_escuela_params

		if escuela_params[:escuela].present?
			carreras = Carrera.getCarreras(escuela_id: escuela_params[:escuela])
			res = {msg: "Carreras obtenidas exitosamente.", type: :success}
			if !carreras.present?
				res[:msg] = "No se encontraron carreras para la escuela seleccionada."
				res[:type] = :warning 
			end

			render json: {msg: res[:msg], type: res[:type], table: render_to_string(partial: 'carreras_table', formats: [:html], layout: false, locals: {carreras: carreras})}

		else
			render json: {msg: "La opción seleccionada es inválida", type: :warning}, status: :unprocessable_entity
		end
	end

	def update_carrera
		carrera_data = update_carrera_params
		carrera_obj = Carrera.find_by(id: carrera_data[:id])

		if !carrera_obj.nil?
			if params[:to_delete] == "1"
				# Eliminar carrera.
				carrera_obj.fecha_eliminacion = DateTime.now
				carrera_obj.save

				carreras = Carrera.getCarreras(escuela_id: carrera_data[:escuela_id])

				render json: {msg: "Carrera eliminada exitosamente.", type: :success, table: render_to_string(partial: 'carreras_table', formats: [:html], layout: false, locals: {carreras: carreras})}

			elsif params[:row_edited] == "1"
				# Editar carrera.
				carrera_obj.assign_attributes(carrera_data.except(:id, :escuela_id))

				if carrera_obj.save
					# Cumplio con las validaciones y se actualiza los datos de la carrera.
					carreras = Carrera.where(escuela_id: carrera_data[:escuela_id])

					render json: {msg: "Datos de carrera actualizadas exitosamente.", type: :success, table: render_to_string(partial: 'carreras_table', formats: [:html], layout: false, locals: {carreras: carreras})}

				else
					# No paso las validaciones.
					render json: {msg: getFormattedAttrObjErrors(carrera_obj.errors.messages, Carrera), type: "danger"}, status: :bad_request
				end

			else
				# Error de opcion.
				render json: {msg: "Ha ocurrido un error con la opción ingresada.", type: 'danger'}, status: 422
			end

		else
			# No se encontro la carrera en la bd con el id dado.
			render json: {msg: "Hubo un error en encontrar la carrera en el sistema."}, status: :bad_request
		end

	end

	def update_asignatura
		asignatura_data = update_asignatura_params
		asignatura_obj = Asignatura.find_by(id: asignatura_data[:id])

		if !asignatura_obj.nil?
			if params[:to_delete] == "1"
				# Eliminar asignatura.

				# Comprobar que la carrera de la asignatura asociada existe.
				carrera_obj = Carrera.select([:id, :nombre]).find_by(id: asignatura_data[:carrera_id])
				if !carrera_obj.nil?
					# Se borra la asociacion de la asignatura con su carrera.
					carrera_obj.asignaturas.delete(asignatura_obj)
					
					asignaturas = carrera_obj.asignaturas
					render json: {msg: "Asignatura eliminada exitosamente.", type: :success, carrera: carrera_obj.nombre, table: render_to_string(partial: 'asignaturas_table', formats: [:html], layout: false, locals: {asignaturas: asignaturas, carrera_id: carrera_obj.id})}
				else
					render json: {msg: "Hubo un problema con el borrado de la asignatura. No existe la carrera asociada.", type: :danger}, status: 422
				end

			elsif params[:row_edited] == "1"
				# Editar asignatura.
				asignatura_obj.assign_attributes(asignatura_data.except(:id, :carrera_id))

				if asignatura_obj.save
					# Cumplio con las validaciones y se actualiza los datos de la carrera.
					asignaturas = Carrera.find_by(id: asignatura_data[:carrera_id]).asignaturas

					render json: {msg: "Datos de asignatura actualizadas exitosamente.", type: :success, table: render_to_string(partial: 'asignaturas_table', formats: [:html], layout: false, locals: {asignaturas: asignaturas, carrera_id: asignatura_data[:carrera_id]})}

				else
					# No paso las validaciones.
					render json: {msg: getFormattedAttrObjErrors(asignatura_obj.errors.messages, Asignatura), type: "danger"}, status: :bad_request
				end

			else
				# Error de opcion.
				render json: {msg: "Ha ocurrido un error con la opción ingresada.", type: 'danger'}, status: 422
			end
		else
			# No se encontro la asignatura en la bd con el id dado.
			render json: {msg: "Hubo un error en encontrar la asignatura en el sistema."}, status: :bad_request
		end
	end

	def get_asignaturas_by_carrera

		if params[:id].present?
			carrera_obj = Carrera.select([:id, :nombre]).find_by(id: params[:id])
			
			if !carrera_obj.nil?
				asignaturas = carrera_obj.asignaturas

				if asignaturas.present?
					render json: {msg: "Asignaturas obtenidas exitosamente.", type: :success, carrera: carrera_obj.nombre, table: render_to_string(partial: 'asignaturas_table', formats: [:html], layout: false, locals: {asignaturas: asignaturas, carrera_id: carrera_obj.id})}

				else
					render json: {msg: "No se encontraron asignaturas para la carrera seleccionada.", type: :warning}, status: :unprocessable_entity
				end
				
			else
				render json: {msg: "Hubo un error en encontrar las asignaturas con la carrera seleccionada.", type: :warning}, status: :unprocessable_entity
			end

		else
			render json: {msg: "Hubo un error en encontrar las asignaturas con la carrera seleccionada.", type: :warning}, status: :unprocessable_entity
		end
		
	end

	# --- FIN METODOS CARRERAS ---

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
				puts "Around ERROR:"
				puts e
				puts "Around ERROR backtrace:"
				puts e.backtrace
				raise e
			end
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

	  def new_carrera_params
	  	params.require(:carrera).permit(:escuela, :file)
	  end

	  def carrera_by_escuela_params
	  	params.require(:escuela).permit(:escuela)
	  end

	  def update_carrera_params
	  	params.require(:carrera).permit(:id, :nombre, :duracion_formal, :codigo, :escuela_id)
	  end
	  
	  def update_asignatura_params
	  	params.require(:asignaturas).permit(:id, :nombre, :codigo, :creditos, :carrera_id)
	  end
end
