class Calificacion < ActiveRecord::Base
	self.table_name =  'calificacion'
	belongs_to :estudiante, class_name: "Estudiante"
	belongs_to :asignatura, class_name: "Asignatura"
	validates_presence_of :estudiante_id, :asignatura_id, :valor_calificacion, :nombre_calificacion, :ponderacion, :periodo_academico

	def self.getCalificaciones(filters = {})
		query = self.includes(:asignatura, estudiante: [:carrera])

		if filters[:carrera].present?
			query = query.select(["carrera.nombre AS nombre_carrera"]).where('carrera.id = ?', filters[:carrera]).references(:carrera)
		end

		if filters[:asignatura].present?
			query = query.where('asignatura.id = ?', filters[:asignatura]).references(:asignatura)
		end
		return query
	end

	def self.getCalificacionesSemestreActual(id_usr)
		data = self.where(estudiante_id: id_usr).where("now() >= periodo_academico AND now() - INTERVAL '6 months' <= periodo_academico").order(asignatura_id: :asc)
		
		if data.present?
			notas_data = []
			asignaturas = data.select([:asignatura_id]).order(asignatura_id: :asc).uniq{|c| c.asignatura_id}

			asignaturas.each do |a|
				hash_data = {
					nombre_asignatura: a.asignatura.nombre,
					notas: data.select{|d| d.asignatura_id == a.asignatura_id}
				}
				notas_data << hash_data
			end

			response = {
				notas: notas_data,
				max_count_notas: self.where(estudiante_id: id_usr).where("now() >= periodo_academico AND now() - INTERVAL '6 months' <= periodo_academico").select(:nombre_calificacion).distinct(:nombre_calificacion).order(nombre_calificacion: :asc)
			}
		else
			response = nil
		end

		return response
	end
end
