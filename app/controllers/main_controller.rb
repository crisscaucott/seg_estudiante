class MainController < ApplicationController

	def index
		estudiantes = Estudiante.getEstudiantes
		estados = EstadoDesercion.getEstados
		render action: :index, locals: {estudiantes: estudiantes, estados: estados}
	end

	def update_estados_estudiantes
		estudiantes = estudiantes_params
		estudiantes_updated = 0
		total = 0

		estudiantes.each do |num, estudiante|
			if estudiante[:row_edited].to_i == 1
				total += 1
				est_obj = Estudiante.select([:id, :estado_desercion_id]).find_by(id: estudiante[:id])
				if !est_obj.nil?
					est_obj.estado_desercion_id = estudiante[:estado_desercion_id].blank? ? nil : estudiante[:estado_desercion_id].to_i
					if est_obj.save
						estudiantes_updated += 1
					end
				end
			end
		end

		estudiantes = Estudiante.getEstudiantes
		estados = EstadoDesercion.getEstados

		render json: {msg: "Se han actualizado exitosamente <b>#{estudiantes_updated}</b> estudiante de los <b>#{total}</b> seleccionados.", type: "success", table: render_to_string(partial: 'estudiantes_table', formats: [:html], layout: false, locals: {estudiantes: estudiantes, estados: estados})}
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

end
