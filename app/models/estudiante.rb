class Estudiante < ActiveRecord::Base
	self.table_name = 'estudiante'
	belongs_to :carrera, class_name: "Carrera"
	has_many :calificacions, class_name: "Calificacion", foreign_key: "estudiante_id"

	def self.getIdEstudianteByCarreraAndRut(rut, carrera_id, fields = [:id])
		return self.select(fields).where(rut: rut.to_s.strip).where(carrera_id: carrera_id).first
	end

	def self.getEstudianteFullNameById(id)
		estudiante_obj = self.select([:nombre, :apellido]).where(id: id).first
		full_name = estudiante_obj.nombre + " " + estudiante_obj.apellido
		return full_name
	end
end
