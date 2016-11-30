class Calificacion < ActiveRecord::Base
	self.table_name =  'calificacion'
	belongs_to :estudiante, class_name: "Estudiante"
	belongs_to :asignatura, class_name: "Asignatura"
	attr_writer :periodo_academico

	def self.getCalificaciones(filters = {})
		query = self.includes(:asignatura, estudiante: [:carrera])

		if !filters[:carrera].nil?
			query = query.select(["carrera.nombre AS nombre_carrera"]).where('carrera.id = ?', filters[:carrera]).references(:carrera)
		end

		if !filters[:asignatura].nil?
			query = query.where('asignatura.id = ?', filters[:asignatura]).references(:asignatura)
		end
		return query
	end
end
