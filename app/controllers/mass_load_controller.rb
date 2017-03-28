class MassLoadController < ApplicationController
	include MassLoadHelper
	include ApplicationHelper
	ANIOS_ATRAS = 10
	CONTEXTS = {
		tutores: 'tutores'
	}
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
			carreras: Carrera.getCarreras(escuela_id: current_user.escuela_id),
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
		carreras = Carrera.getCarreras
		render action: :index, locals: {partial: 'asistencia', report: report, context: 'asistencia', carreras: carreras}
	end

	def get_asistencia
		asistencias = Asistencia.getAsistencias()
		filtro_asistencia = {
			carreras: Carrera.getCarreras(escuela_id: current_user.escuela_id),
			periodos: years_ago = Date.today.year.downto(Date.today.year - ANIOS_ATRAS).to_a
		}

		render action: :index, locals: {partial: 'get_asistencia', context: 'asistencia', asistencias: asistencias, filtros: filtro_asistencia, periodo: -1}
	end

	def get_asistencia_filtering
		filter_params = asistencia_filter_params
		asistencias = Asistencia.getAsistencias(filter_params)
		periodo = filter_params[:periodo].present? ? filter_params[:periodo] : -1

		if asistencias.present?
			render json: {msg: "Datos de estudiantes con sus asistencias obtenidos exitosamente.", type: :success, table: render_to_string(partial: 'asistencia_table', formats: [:html], layout: false, locals: {asistencias: asistencias, periodo: periodo})}

			# render json: {msg: "Datos de estudiantes con sus asistencias obtenidos exitosamente.", type: :success, asistencias: asistencias}, include: [:asignatura, estudiante: {include: :carrera}]

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
		if params[:asistencia][:carrera].present?
			carrera_obj = Carrera.select(:id).find_by(id: params[:asistencia][:carrera])

			if !carrera_obj.nil?
				uploaded_file = uploadFile(params[:asistencia][:file])

				if !uploaded_file[:file_path].nil?
					# Subir excel con asistencia.
					mass_load_obj = LogCargaMasiva.new(usuario_id: current_user.id, url_archivo: uploaded_file[:file_path])
					
					res = mass_load_obj.uploadAssistance(carrera_obj.id)

					if !res[:error]
						render json: {msg: render_to_string(partial: 'detalle_subida_asistencia', formats: [:html], layout: false, locals: {detail: res[:msg]}), type: "success"}
					else
						render json: {msg: res[:msg]}, status: :unprocessable_entity
					end

				else
					# Problema con guardar el fichero
					render json: {msg: "Ha ocurrido un problema en guardar el archivo."}, status: :unprocessable_entity
				end
			else
				render json: {msg: "Ha ocurrido un problema en encontrar la carrera seleccionada."}, status: :unprocessable_entity
			end

		else
			render json: {msg: "Debe seleccionar una carrera para poder subir la asistencia."}, status: :unprocessable_entity
			
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
				render json: {resumen_url: url_for(resumen_subida_path(mass_load_obj.id)),msg: render_to_string(partial: 'detalle_subida_estudiante', formats: [:html], layout: false, locals: {detail: res[:msg]}), type: "success"}
				
			else
				render json: {msg: res[:msg], type: "danger"}, status: :bad_request
			end
		else
			render json: {msg: "Ha ocurrido un problema en guardar el archivo."}, status: :unprocessable_entity
		end
	end

	def resumen_subida_estudiantes
		carga_masiva_obj = LogCargaMasiva.find_by(id: params[:id])

		if !carga_masiva_obj.nil?
			file_name = "Resumen_carga_de_estudiantes(#{carga_masiva_obj.id})-#{carga_masiva_obj.created_at.strftime("%Y-%m-%d")}.txt"
			file = File.new(file_name, "w")

			# Escribir el nombre del usuario que subio el excel.
			file.puts("Subido por: #{carga_masiva_obj.usuario.name} #{carga_masiva_obj.usuario.last_name}")

			# Escribir la fecha y hora de cuando se subio el excel. 
			file.puts("Subido a las: #{carga_masiva_obj.created_at.strftime("%Y-%m-%d %H:%M")}")

			# Total estudiantes dentro del excel.
			file.puts("Nº total de estudiantes del excel: #{carga_masiva_obj.detalle['total']}")

			# Estudiantes nuevos.
			file.puts("Nº de estudiantes subidos como nuevos: #{carga_masiva_obj.detalle['new'].size}")

			if carga_masiva_obj.detalle['new'].size != 0
				file.puts("#{carga_masiva_obj.detalle["new"].join(", ")}\n")
			end

			# Estudiantes actualizados.
			file.puts("Nº de estudiantes encontrados en el sistema y actualizados: #{carga_masiva_obj.detalle['upd'].size}")

			if carga_masiva_obj.detalle['upd'].size != 0
				file.puts("#{carga_masiva_obj.detalle["upd"].join(", ")}\n")
			end

			# Estudiantes no subidos por error.
			file.puts("Nº de estudiantes que no se subieron: #{carga_masiva_obj.detalle['failed'].size}")

			if carga_masiva_obj.detalle['failed'].size != 0
				file.puts("#{carga_masiva_obj.detalle["failed"].join(", ")}\n")
			end

			file.close()

			File.open(Rails.root.join(file_name) ,'r') do |f|
		  	send_data f.read, :type => "application/text", :disposition => "attachment", filename: file_name
			end

			File.delete(Rails.root.join(file_name))
		end
	end

	# --- FIN METODOS ESTUDIANTES ---

	# --- METODOS TUTORES ---

	def asociar_tutores_est_index
		estudiantes = Estudiante.getEstudiantesByUserType(current_user)
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

	def get_estudiantes_params
		params.require(:users).permit(:id)
	end
	
	def tutores_est_params
		params.require(:users).permit(:id, estudiantes: [id: []])
	end

	def notas_filter_params
		params.require(:filters).permit(:carrera, :asignatura)
	end

	def asistencia_filter_params
		params.require(:filters).permit(:carrera, :asignatura, :periodo)
	end

	def asistencia_detail_filter_params
		params.permit(:asignatura_id, :estudiante_id, :periodo)
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
