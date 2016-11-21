class MainController < ApplicationController

	def index

	end

	def notas
		@report = Reporte.new
	end

	def uploadXls
		uploaded_io = params[:reporte][:nombre_reporte]
		File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
		  file.write(uploaded_io.read)
		end

		respond_to do |format|
			@repo = Reporte.new({nombre_reporte: uploaded_io.original_filename, tipo_reporte: 'xls', usuario_id: current_user.id})

			@repo.save

			format.html{
				render template: notas_path
				
			}
			format.json{
				render json: {msg: 'Archivo subido exitosamente.'}
			}
		end
	end

	def reportes
		
	end

	def observaciones
		
	end

	def caracteristicas
		
	end

end
