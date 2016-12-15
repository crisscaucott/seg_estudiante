class MassLoadController < ApplicationController
	include MassLoadHelper
	include ApplicationHelper
	ANIOS_ATRAS = 10
	around_filter :checkUpload, only: [:uploadXls, :uploadAssistance, :subir_estudiantes_xls]
	before_filter :isTutorOrDecano ,only: [:subir_estudiantes, :subir_estudiantes_xls]

	def index
		render action: :index, locals: {context: nil}
	end

	def notas
		report = Reporte.new
		render action: :index, locals: {partial: 'notas',  report: report, context: 'notas'}
	end

	def get_notas
		calificaciones = Calificacion.getCalificaciones
		filtro_notas = {
			carreras: Carrera.getCarreras,
		}
		render action: :index, locals: {partial: 'ver_notas', calificaciones: calificaciones, filtros: filtro_notas, context: 'notas'}
	end

	def uploadXls
		uploaded_file = uploadFile(params[:reporte][:nombre_reporte])

		if !uploaded_file[:file_path].nil?
			# Subir excel con las notas.
			mass_load_obj = LogCargaMasiva.new(usuario_id: current_user.id, url_archivo: uploaded_file[:file_path])
			
			res = mass_load_obj.uploadNotas()
			if !res[:error]
				render json: {msg: render_to_string(partial: 'detalle_subida_notas', formats: [:html], layout: false, locals: {detail: res[:msg]}), type: "success"}
			else
				render json: {msg: res[:msg]}, status: :unprocessable_entity
			end
		else
			# Problema con guardar el fichero
			render json: {msg: "Ha ocurrido un problema en guardar el archivo."}, status: :unprocessable_entity
		end
	end

	def getAsignaturasByCarrera
		carrera_obj = Carrera.select([:id, :nombre]).find_by(id: params[:carrera_id])

		if !carrera_obj.nil?
			asignaturas = carrera_obj.asignaturas.select([:id, :nombre]).order(nombre: :asc)

			if asignaturas.size != 0
				render json: {msg: "Asignaturas obtenidas exitosamente.", asignaturas: asignaturas, type: :success}
			else
				render json: {msg: "No se encontraron asignaturas con la carrera elegida.", type: :warning}, status: :unprocessable_entity
			end

		else
			render json: {msg: "Hubo un problema en encontrar la carrera seleccionada en el sistema.", type: :warning}, status: :unprocessable_entity			
		end
	end

	def get_notas_filtering
		filters = notas_filter_params
		calificaciones = Calificacion.getCalificaciones(filters)

		if calificaciones.size != 0
			# calificaciones.map{|c| c.periodo_academico = formatDateToSemesterPeriod(c.periodo_academico) }

			render json: {msg: "Datos de calificaciones obtenidos exitosamente.", calificaciones: calificaciones}, include: [:asignatura, estudiante: {include: :carrera}]
		else
			render json: {msg: "No se han encontrado calificaciones con los filtrados definidos.", type: "warning"}, status: :unprocessable_entity
		end
	end

	def asistencia
		report = Reporte.new
		render action: :index, locals: {partial: 'asistencia', report: report, context: 'asistencia'}
	end

	def get_asistencia
		asistencias = Asistencia.getAsistencias()
		filtro_asistencia = {
			carreras: Carrera.getCarreras,
			asignaturas: Asignatura.getAsignaturas,
			periodos: years_ago = Date.today.year.downto(Date.today.year - ANIOS_ATRAS).to_a
		}
		
		render action: :index, locals: {partial: 'get_asistencia', context: 'asistencia', asistencias: asistencias, filtros: filtro_asistencia}
	end

	def get_asistencia_filtering
		filter_params = asistencia_filter_params
		asistencias = Asistencia.getAsistencias(filter_params)

		if asistencias.present?
			render json: {msg: "Datos de estudiantes con sus asistencias obtenidos exitosamente.", type: :success, asistencias: asistencias}, include: [:asignatura, estudiante: {include: :carrera}]

		else
			render json: {msg: "No se han encontrado estudiantes con los filtros definidos.", type: :warning, asistencias: asistencias}
		end

	end

	def get_asistencia_detail
		asis_params = asistencia_detail_filter_params
		asistencia_detail = Asistencia.getAsistenciaDetail(asis_params)

		titulo = "Asistencia del alumno <b>'" + Estudiante.getEstudianteFullNameById(asis_params[:estudiante_id]) + "'</b>, en la asignatura de <b>'" + Asignatura.getAsignaturaNameById(asis_params[:asignatura_id]) + "'</b>."

		if asistencia_detail.size != 0
			render json: {msg: "Asistencia obtenidas exitosamente.", type: "success", title: titulo, table: render_to_string(partial: 'asistencia_detalle', formats: [:html], layout: false, locals: {asistencia: asistencia_detail})}
		else
			render json: {msg: "El alumno solicitado no presenta asistencias guardada en el sistema.", type: "warning"}, status: :unprocessable_entity
		end
	end

	def uploadAssistance
		uploaded_file = uploadFile(params[:reporte][:file])

		if !uploaded_file[:file_path].nil?
			# Subir excel con asistencia.
			mass_load_obj = LogCargaMasiva.new(usuario_id: current_user.id, url_archivo: uploaded_file[:file_path])
			
			res = mass_load_obj.uploadAssistance()

			if !res[:error]
				render json: {msg: render_to_string(partial: 'detalle_subida_asistencia', formats: [:html], layout: false, locals: {detail: res[:msg]}), type: "success"}
			else
				render json: {msg: res[:msg]}, status: :unprocessable_entity
			end

		else
			# Problema con guardar el fichero
			render json: {msg: "Ha ocurrido un problema en guardar el archivo."}, status: :unprocessable_entity
		end

	end

	def alumnos
		render action: :index, locals: {partial: 'alumnos', context: 'alumnos'}
		
	end

	def get_alumnos
		render action: :index, locals: {partial: 'get_alumnos', context: 'alumnos'}
		
	end

	# --- METODOS ESTUDIANTES ---

	def subir_estudiantes
		
		render action: :index, locals: {partial: 'subir_estudiantes', context: 'alumnos', file: LogCargaMasiva.new}
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


	def notas_filter_params
		params.require(:filters).permit(:carrera, :asignatura)
	end

	def asistencia_filter_params
		params.require(:filters).permit(:carrera, :asignatura, :periodo)
	end

	def asistencia_detail_filter_params
		params.permit(:estudiante_id, :asignatura_id)
	end

	def subir_estudiante_params
		params.require(:log_carga_masiva).permit(:url_archivo)
	end

	def isTutorOrDecano
		if !(current_user.user_permission.name == "Decano" || current_user.user_permission.name == "Director")
			flash[:msg] = "Usted no tiene los permisos para estar en esta sección."
    	flash[:alert_type] = :warning
    	flash.keep(:msg)
    	flash.keep(:alert_type)
			redirect_to action: "index", status: 301
		end
	end

	def checkUpload
		begin
			yield
		rescue StandardError => e
			if e.backtrace[0] =~ /log_carga_masiva/i
				render json: {msg: "Error de lectura del excel.", type: :danger}, status: :bad_request
			else
				render json: {msg: "Error inesperado.", type: :danger}, status: :bad_request
			end
		end
	end

end
