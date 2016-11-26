class Estudiante < ActiveRecord::Base
	self.table_name = 'estudiante'

	belongs_to :carreras
end
