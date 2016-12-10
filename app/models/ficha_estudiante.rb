class FichaEstudiante < ActiveRecord::Base
	self.table_name = 'ficha_estudiante'
	belongs_to :estudiante, class_name: "Estudiante", foreign_key: :estudiante_id
	belongs_to :tutor, class_name: "User", foreign_key: :tutor_id
	belongs_to :estado_desercion, class_name: "EstadoDesercion", foreign_key: :estado_desercion_id
	belongs_to :motivo_desercion, class_name: "MotivoDesercion", foreign_key: :motivo_desercion_id
	belongs_to :destino, class_name: "Destino", foreign_key: :destino_id

	validates_presence_of :estudiante_id, :tutor_id, :estado_desercion_id, :fecha_registro

end
