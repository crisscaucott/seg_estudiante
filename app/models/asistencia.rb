class Asistencia < ActiveRecord::Base
	belongs_to :estudiante, class_name: "Estudiante"
	belongs_to :asignatura, class_name: "Asignatura"
	has_one :estado_asistencia, class_name: "EstadosAsistencia", foreign_key: :id, primary_key: :estado_asistencia_id

	def self.getAsistencias(filters = {})
		query = self.includes(:asignatura, :estudiante).select([:estudiante_id, :asignatura_id]).group(:estudiante_id, :asignatura_id)

		if !filters[:estudiante_id].nil?
			query = query.where(estudiante_id: filters[:estudiante_id])
		end

		# if !filters[:carrera].nil?
		# 	query = query.where('carrera.id = ?', filters[:carrera]).references(:carrera)
		# end

		if filters[:periodo].present?
			since_date = "#{filters[:periodo]}-01-01"
			until_date = "#{filters[:periodo].to_i + 1}-01-01"
			query = query.where("(fecha_asistida >= ? AND fecha_asistida < ?)", since_date, until_date)
		end

		if filters[:asignatura].present?
			query = query.where(asignatura_id: filters[:asignatura])
		end

		return query
	end

	def self.getAsistenciaDetail(filters)
		return self.includes(:estado_asistencia).select(:estudiante_id, :asignatura_id, :fecha_asistida, :estado_asistencia_id).where(estudiante_id: filters[:estudiante_id]).where(asignatura_id: filters[:asignatura_id])
	end

end