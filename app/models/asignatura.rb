class Asignatura < ActiveRecord::Base
	include StrFormats
	self.table_name = 'asignatura'
	has_and_belongs_to_many :carreras
	has_many :calificacions, class_name: "Calificacion", foreign_key: "asignatura_id"

	def self.getAsignaturas
		return self.select([:id, :nombre]).where(fecha_borrado: nil).order(nombre: :asc)
	end

	def self.getAsignaturaNameById(id)
		return self.select(:nombre).where(id: id).first.nombre
	end

	def nombre=(new_nombre)
		new_nombre = new_nombre.strip
		self[:nombre] = new_nombre.capitalize
		self[:nombre_formateado] = getFormattedLike(new_nombre)
	end

end
