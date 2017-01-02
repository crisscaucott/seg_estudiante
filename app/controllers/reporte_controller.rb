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
		pdf = ReportePdf.new

    file_path = Rails.root.join('public', 'pdfs', 'prueba.pdf')
    pdf.render_file(file_path)

		render json: {msg: "bien", type: :success, pdf_url: '/reportes/download_pdf?file=prueba'}
	end

	def download_pdf
		file = Rails.root.join('public', 'pdfs', params[:file] + '.pdf')
		File.open(file, 'r') do |f|
		  send_data f.read, :type => "application/pdf", :disposition => "attachment"
		end
		File.delete(file)
	end

end
