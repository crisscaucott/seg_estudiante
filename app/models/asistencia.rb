class Asistencia < ActiveRecord::Base
	belongs_to :estudiante, class_name: "Estudiante"
	belongs_to :asignatura, class_name: "Asignatura"

	def self.getAsistencias(filters = {})
		return self.includes(:asignatura, :estudiante).select([:estudiante_id, :asignatura_id]).group(:estudiante_id, :asignatura_id)
	end

	def self.getAsistenciaDetail(filters)
		return self.select(:estudiante_id, :asignatura_id, :fecha_asistida, :valor_asistencia).where(estudiante_id: filters[:estudiante_id]).where(asignatura_id: filters[:asignatura_id])
	end

end