class Asignatura < ActiveRecord::Base
	self.table_name = 'asignatura'
	has_and_belongs_to_many :carreras
	has_many :calificacions, class_name: "Calificacion", foreign_key: "asignatura_id"

	def self.getAsignaturas
		return self.select([:id, :nombre]).where(fecha_borrado: nil).order(nombre: :asc)
	end

	def self.getAsignaturaNameById(id)
		return self.select(:nombre).where(id: id).first.nombre
	end

end
