class EstilosAprendizaje < ActiveRecord::Base
	self.table_name = "estilos_aprendizaje"
	belongs_to :estudiante, class_name: "Estudiante", foreign_key: :estudiante_id

	validates_presence_of :estudiante_id

	def self.getEstilosByEstudiante(estudiante_id)
		return self.where(estudiante_id: estudiante_id)
	end
end
