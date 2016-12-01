class EstadoDesercion < ActiveRecord::Base
	self.table_name = 'estado_desercion'

	validates_presence_of :nombre_estado

	def getEstadoDesercion
		# byebug
		return EstadoDesercion.exists?(nombre_estado: self.nombre_estado)
	end

	def nombre_estado=(new_nombre_estado)
		self[:nombre_estado] = new_nombre_estado.strip.capitalize
	end

	def getFormatErrorMessages
		error_str = ''
  	self.errors.messages.each do |field, error|
  		case field
  			when :nombre_estado
  				error_str += "<b>Nombre estado:</b> " + error.join(',') + "<br>"

        when :notificar
          error_str += "<b>Nofificar:</b> " + error.join(',') + "<br>"
          
  		end
  	end

  	return error_str.html_safe
	end
end
