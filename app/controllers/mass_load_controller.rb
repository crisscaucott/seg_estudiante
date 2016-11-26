class MassLoadController < ApplicationController
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
end
