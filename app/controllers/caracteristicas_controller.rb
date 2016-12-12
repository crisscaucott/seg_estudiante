class CaracteristicasController < ApplicationController

	def index
		
		render action: :index, locals: {context: nil}
	end

	def subir_perfiles_index
		render action: :index, locals: {partial: 'subir_perfiles', context: 'estilos', file: LogCargaMasiva.new}
	end

end
