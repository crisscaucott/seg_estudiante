class EstadoDesercion < ActiveRecord::Base
	self.table_name = 'estado_desercion'
	DESERTO_ESTADO = "Desertó"
	DESERTO_NINGUNO = "Ninguno"
	has_many :estudiante, class_name: "Estudiante", foreign_key: "estado_desercion_id"

	validates_presence_of :nombre_estado

	def self.getEstados()
		return self.all.order(nombre_estado: :asc)
	end

	def getEstadoDesercion(id = nil)
		if id.nil?
			return EstadoDesercion.exists?(nombre_estado: self.nombre_estado)
		else
			return EstadoDesercion.exists?(["nombre_estado = ? AND id != ?", self.nombre_estado, id])
		end
	end

	def checkIsEstadoFijo
		if self.nombre_estado == DESERTO_ESTADO || self.nombre_estado == DESERTO_NINGUNO
			return true
		else
			return false
		end
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
