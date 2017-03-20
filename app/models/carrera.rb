class Carrera < ActiveRecord::Base
	include StrFormats
	self.table_name = 'carrera'
	has_and_belongs_to_many :asignaturas
	has_many :estudiantes, class_name: "Estudiante", foreign_key: "carrera_id"
	belongs_to :escuela, class_name: "Escuela", foreign_key: :escuela_id

	def self.getCarreras(filters = {})
		carreras = self.order(nombre: :asc)

		if filters[:escuela_id].present?
			carreras = carreras.where(escuela_id: filters[:escuela_id])
		end

		if !(filters[:borrado].present? && filters[:borrado])
			carreras = carreras.where(fecha_eliminacion: nil)
		end

		return carreras
	end

	def getEstudiantesDesertores(fecha_ingreso, only_count = false)
		query = self.estudiantes.joins(:estado_desercion).merge(EstadoDesercion.where(nombre_estado: "Desertó")).where(fecha_ingreso: "#{fecha_ingreso}-01-01"..."#{fecha_ingreso + 1}-01-01")

		if only_count
			query = query.size
		end

		return query
	end

	def nombre=(new_nombre)
		new_nombre = new_nombre.strip
		self[:nombre] = new_nombre.capitalize
		self[:nombre_formateado] = getFormattedLike(new_nombre)
	end

	def nombre_formateado=(new_nombre)
		self[:nombre_formateado] = getFormattedLike(new_nombre)
	end

end
