class Estudiante < ActiveRecord::Base
	self.table_name = 'estudiante'
	belongs_to :carreras

	def self.getIdEstudianteByCarreraAndRut(rut, carrera_id, fields = [:id])
		return self.select(fields).where(rut: rut.to_s.strip).where(carrera_id: carrera_id).first
	end
end
