class MainController < ApplicationController
	ANIOS_ATRAS = 10

	def index
		estudiantes = Estudiante.getEstudiantesByUserType(current_user)

		filters = {
			carreras: Carrera.getCarreras(escuela_id: current_user.escuela_id),
			estados_desercion: EstadoDesercion.getEstados,
			anios_ingreso: years_ago = Date.today.year.downto(Date.today.year - ANIOS_ATRAS).to_a
		}

		if estudiantes === false
			flash[:msg] = "Ha ocurrido un problema en obtener los estudiantes en el sistema."
			flash[:alert_type] = :danger
			estudiantes = []
		end

		if current_user.user_permission.name == "Usuario normal"
			partial = 'estudiantes_table'
		else
			partial = 'estudiantes_table_editable'
		end

		render action: :index, locals: {estudiantes: estudiantes, estados: filters[:estados_desercion], filters: filters, partial: partial}
	end

	def update_estados_estudiantes
		estudiantes = estudiantes_params
		estudiantes_updated = 0
		total = 0

		estudiantes.each do |num, estudiante|
			if estudiante[:row_edited].to_i == 1
				total += 1
				est_obj = Estudiante.find_by(id: estudiante[:id])
				if !est_obj.nil?
					update_fields = estudiantes_permitted_fields(estudiante)
					est_obj.assign_attributes(update_fields)
					# est_obj.estado_desercion_id = estudiante[:estado_desercion_id].blank? ? nil : estudiante[:estado_desercion_id].to_i
					if est_obj.save
						estudiantes_updated += 1
					end
				end
			end
		end

		estudiantes = Estudiante.getEstudiantesByUserType(current_user)
		estados = EstadoDesercion.getEstados

		render json: {msg: "Se han actualizado exitosamente <b>#{estudiantes_updated}</b> estudiante de los <b>#{total}</b> seleccionados.", type: "success", table: render_to_string(partial: 'estudiantes_table_editable', formats: [:html], layout: false, locals: {estudiantes: estudiantes, estados: estados})}
	end

	def getDetalleEstudiante
		est_obj = Estudiante.find_by(id: params[:id])

		if !est_obj.nil?
			calificaciones = Calificacion.getCalificacionesSemestreActual(est_obj.id)
			asistencias = Asistencia.getAsistencias(estudiante_id: est_obj.id)
			estilos = EstilosAprendizaje.getEstilosByEstudiante(est_obj.id)
			fichas = FichaEstudiante.getFichaByEstudiante(est_obj.id)

			render json: {msg: "Información del estudiante obtenida exitosamente.", type: :success, table: render_to_string(partial: 'estudiantes_info', formats: [:html], layout: false, locals: {estudiante: est_obj, calificaciones: calificaciones, asistencias: asistencias, estilos: estilos, fichas: fichas})}

		else
			render json: {msg: "Hubo un error en encontrar el estudiante en el sistema.", type: :danger}, status: :bad_request
		end

	end

	def get_estudiantes_filtering
		filters = estudiantes_filter_params
		estudiantes = Estudiante.getEstudiantesByUserType(current_user, filters)

		if estudiantes.size != 0
			if current_user.user_permission.name == "Usuario normal"
				partial = 'estudiantes_table'
			else
				partial = 'estudiantes_table_editable'
			end

			estados = EstadoDesercion.getEstados
			render json: {msg: "Estudiantes obtenidos con los filtros definidos exitosamente.", type: "success", table: render_to_string(partial: partial, formats: [:html], layout: false, locals: {estudiantes: estudiantes, estados: estados})}
		else
			render json: {msg: "No se encontraron estudiantes con los filtros definidos.", type: :warning}
		end
	end

	def mass_load
	end

	def uploadAssistance
		
	end

	def reportes
		
	end

	def observaciones
		
	end

	def caracteristicas
		
	end

	def estudiantes_params
		params.require(:estudiantes)
	end

	def estudiantes_permitted_fields(hash)
		return hash.permit(:nombre, :apellido, :estado_desercion_id)
	end

	def estudiantes_filter_params
		params.require(:estudiantes_filter).permit(:anio_ingreso, :carrera, :estado_desercion)
	end

end
