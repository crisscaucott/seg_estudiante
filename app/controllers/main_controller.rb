class MainController < ApplicationController

	def index
		estudiantes = Estudiante.getEstudiantes
		estados = EstadoDesercion.getEstados
		render action: :index, locals: {estudiantes: estudiantes, estados: estados}
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

end
