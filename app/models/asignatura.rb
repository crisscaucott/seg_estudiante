class Asignatura < ActiveRecord::Base
	has_and_belongs_to_many :carreras

end
