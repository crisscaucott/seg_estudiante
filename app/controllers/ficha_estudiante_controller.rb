class FichaEstudianteController < ApplicationController
	include ApplicationHelper
	before_filter :isTutor

	def ficha_estudiante_index
		estudiantes = current_user.estudiantes.includes(:carrera).select([:id, :nombre, :apellido, :rut, :carrera_id])
		estados_desercion = EstadoDesercion.getEstados
		motivos = MotivoDesercion.getMotivos
		destinos = Destino.getDestinos
		
		render action: :index, locals: {ficha: FichaEstudiante.new, estudiantes: estudiantes, estados_desercion: estados_desercion, motivos: motivos, destinos: destinos}
	end

	def save_ficha_estudiante
		ficha_params = ficha_estudiante_params
		ficha_obj = FichaEstudiante.new(ficha_params)
		ficha_obj.tutor_id = current_user.id

		if ficha_obj.valid?
			ficha_obj.save
			render json: {msg: "Ficha de estudiante ingresada exitosamente.", type: :success}

		else
			render json: {msg: getFormattedAttrObjErrors(ficha_obj.errors.messages, FichaEstudiante), type: :danger}, status: :bad_request
		end

	end


	private
		def isTutor
			if !isUserType('Tutor')
				flash[:msg] = "Usted no tiene los permisos para estar en esta sección."
	    	flash[:alert_type] = :warning
	    	flash.keep(:msg)
	    	flash.keep(:alert_type)
				redirect_to :root, status: 301
			end
		end

		def ficha_estudiante_params
			params.require(:ficha_estudiante).permit(:estudiante_id, :estado_desercion_id, :motivo_desercion_id, :destino_id, :fecha_registro, :comentario)
		end

end
