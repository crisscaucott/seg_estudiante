class Calificacion < ActiveRecord::Base
	self.table_name =  'calificacion'
	belongs_to :estudiante, class_name: "Estudiante"
	belongs_to :asignatura, class_name: "Asignatura"
end
