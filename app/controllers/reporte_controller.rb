class ReporteController < ApplicationController
	ANIOS_ATRAS = 10
	include ApplicationHelper

	def index
		filters = {
			carreras: Carrera.getCarreras(escuela_id: current_user.escuela_id),
			estados_desercion: EstadoDesercion.getEstados,
			anios_ingreso: years_ago = Date.today.year.downto(Date.today.year - ANIOS_ATRAS).to_a
		}

		render action: :index, locals:{filters: filters}
	end

	def generate_pdf
		pdf_params = generate_pdf_params()
		pdf = ReportePdf.new(pdf_params)

    file_path = Rails.root.join('tmp', 'prueba.pdf')
    pdf.render_file(file_path)

		render json: {msg: "Reporte generado exitosamente.", type: :success, pdf_url: '/reportes/download_pdf?file=prueba'}
	end

	def download_pdf
		file = Rails.root.join('tmp', params[:file] + '.pdf')
		File.open(file, 'r') do |f|
		  send_data f.read, :type => "application/pdf", :disposition => "attachment"
		end
		File.delete(file)
	end

	def generate_pdf_params
		params.require(:reporte).permit(:anio_ingreso, :carrera)
	end

end
