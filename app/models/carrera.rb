class Carrera < ActiveRecord::Base
	self.table_name = 'carrera'
	has_and_belongs_to_many :asignaturas
	has_many :estudiantes, class_name: "Estudiante", foreign_key: "carrera_id"

	def self.getCarreras
		return self.select([:id, :nombre]).order(nombre: :asc)
	end
end
