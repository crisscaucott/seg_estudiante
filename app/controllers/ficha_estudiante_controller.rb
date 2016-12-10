class FichaEstudianteController < ApplicationController
	include ApplicationHelper
	before_filter :isTutor

	def ficha_estudiante_index
		
		render action: :index, locals: {context: nil}
	end


	private
		def isTutor
			if !isUserType('Tutor')
				flash[:msg] = "Usted no tiene los permisos para estar en esta sección."
	    	flash[:alert_type] = :warning
	    	flash.keep(:msg)
	    	flash.keep(:alert_type)
				redirect_to :root, status: 301
			end
		end

end
