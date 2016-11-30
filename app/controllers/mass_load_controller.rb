class MassLoadController < ApplicationController
	include MassLoadHelper

	def index
	end

	def notas
		report = Reporte.new
		render action: :index, locals: {partial: 'notas',  report: report, context: 'notas'}
	end

	def get_notas
		calificaciones = Calificacion.getCalificaciones
		filtro_notas = {
			carreras: Carrera.getCarreras,
			asignaturas: Asignatura.getAsignaturas
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
				render json: {msg: res[:msg]}
			else
				render json: {msg: res[:msg]}, status: :unprocessable_entity
			end
		else
			# Problema con guardar el fichero
			render json: {msg: "Ha ocurrido un problema en guardar el archivo."}, status: :unprocessable_entity
		end
	end

	def get_notas_filtering
		filters = notas_filter_params
		calificaciones = Calificacion.getCalificaciones(filters)

		if calificaciones.size != 0
			byebug
			calificaciones.map{|c| c.periodo_academico = formatDateToSemesterPeriod(c.periodo_academico) }


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
		render action: :index, locals: {partial: 'get_asistencia', context: 'asistencia'}
	end

	def uploadAssistance
		uploaded_file = uploadFile(params[:reporte][:file])

		if !uploaded_file[:file_path].nil?
			# Subir excel con asistencia.
			mass_load_obj = LogCargaMasiva.new(usuario_id: current_user.id, url_archivo: uploaded_file[:file_path])
			
			res = mass_load_obj.uploadAssistance()

			if !res[:error]
				render json: {msg: res[:msg]}
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


	def notas_filter_params
		params.require(:filters).permit(:carrera, :asignatura)
	end
end
