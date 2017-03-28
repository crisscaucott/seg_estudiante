class EstadosAsistencia < ActiveRecord::Base
	self.table_name = "estados_asistencia"
	has_many :asistencia, class_name: "Asistencia", foreign_key: :estado_asistencia_id

end
