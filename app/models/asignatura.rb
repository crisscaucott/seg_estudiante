class Asignatura < ActiveRecord::Base
	self.table_name = 'asignatura'
	has_and_belongs_to_many :carreras
	has_many :calificacions, class_name: "Calificacion", foreign_key: "asignatura_id"

end
