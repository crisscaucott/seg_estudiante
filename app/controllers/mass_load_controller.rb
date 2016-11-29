class MassLoadController < ApplicationController
	include MassLoadHelper

	def notas
		report = Reporte.new
		render action: :index, locals: {partial: 'notas',  report: report}
	end

	def asistencia
		report = Reporte.new
		render action: :index, locals: {partial: 'asistencia', report: report}
	end

	def alumnos
		
	end

	def index
	end

	def get_notas
		calificaciones = Calificacion.getCalificaciones
		filtro_notas = {
			carreras: Carrera.getCarreras,
			asignaturas: Asignatura.getAsignaturas
		}
		render action: :index, locals: {partial: 'ver_notas', calificaciones: calificaciones, filtros: filtro_notas}
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

	def getAlumnos
		
	end

	def getAsistencia
		
	end

	def uploadAssistance
		uploaded_file = uploadFile(params[:reporte][:file])


		if !uploaded_file[:file_path].nil?
			# Subir excel con asistencia.
			mass_load_obj = LogCargaMasiva.new(usuario_id: current_user.id, url_archivo: uploaded_file[:file_path])
			
			res = mass_load_obj.uploadAssistance()
			render json: {msg: "Excel con asistencia subida exitosamente."}
		else
			# Problema con guardar el fichero
			render json: {msg: "Ha ocurrido un problema en guardar el archivo."}, status: :unprocessable_entity
		end

	end

	def notas_filter_params
		params.require(:filters).permit(:carrera, :asignatura)
	end
end
