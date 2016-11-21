class MainController < ApplicationController

	def index

	end

	def notas
		@report = Reporte.new
	end

	def uploadXls
		uploaded_io = params[:reporte][:nombre_reporte]
		excel_file = Rails.root.join('public', 'xls', uploaded_io.original_filename)
		File.open(excel_file, 'wb') do |file|
		  file.write(uploaded_io.read)
		end

		LogCargaMasiva.readExcelFile(excel_file)

		respond_to do |format|
			# @repo = Reporte.new({nombre_reporte: uploaded_io.original_filename, tipo_reporte: 'xls', usuario_id: current_user.id})

			# @repo.save

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
