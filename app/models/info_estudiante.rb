class InfoEstudiante < ActiveRecord::Base
	self.table_name = 'info_estudiante'

	belongs_to :estudiante, class_name: "Estudiante", foreign_key: :estudiante_id
end
