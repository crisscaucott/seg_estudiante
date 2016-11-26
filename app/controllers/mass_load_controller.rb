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


	def uploadAssistance
		uploaded_file = uploadFile(params[:reporte][:file])
		if !uploaded_file[:file_path].nil?
			mass_load_obj = LogCargaMasiva.new(usuario_id: current_user.id)


		else
			# Problema con guardar el fichero
			render json: {msg: "Ha ocurrido un problema en guardar el archivo."}, status: :unprocessable_entity
		end

	end

end
