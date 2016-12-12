class CaracteristicasController < ApplicationController
	include MassLoadHelper

	def index
		
		render action: :index, locals: {context: nil}
	end

	def perfiles_index
		render action: :index, locals: {partial: 'subir_perfiles', context: 'estilos', file: LogCargaMasiva.new}
	end

	def subir_perfiles
		perfiles_params = subir_perfiles_params
		uploaded_file = uploadFile(perfiles_params[:url_archivo])

		if !uploaded_file[:file_path].nil?
			# Subir excel con asistencia.
			mass_load_obj = LogCargaMasiva.new(usuario_id: current_user.id, url_archivo: uploaded_file[:file_path])
			
			res = mass_load_obj.uploadPerfiles()

			if !res[:error]
				render json: {msg: render_to_string(partial: 'detalle_subida_estilos', formats: [:html], layout: false, locals: {detail: res[:msg]}), type: :success}
			else
				render json: {msg: res[:msg]}, status: :unprocessable_entity
			end

		else
			# Problema con guardar el fichero
			render json: {msg: "Ha ocurrido un problema en guardar el archivo."}, status: :unprocessable_entity
		end

	end

	private
		def subir_perfiles_params
			params.require(:log_carga_masiva).permit(:url_archivo)
		end
end
