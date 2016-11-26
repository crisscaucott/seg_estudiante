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

		res = LogCargaMasiva.readExcelFile(excel_file, current_user.id)

		respond_to do |format|
			format.html{
				render template: notas_path
				
			}
			format.json{
				if !res[:error]
					render json: {msg: res[:msg]}
				else
					render json: {msg: res[:msg]}, status: :unprocessable_entity
				end
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
