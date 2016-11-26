class Asignatura < ActiveRecord::Base
	self.table_name = 'asignatura'
	has_and_belongs_to_many :carreras

end
