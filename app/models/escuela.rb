class Escuela < ActiveRecord::Base
	self.table_name = 'escuela'
	has_many :carreras, class_name: "Carrera"
	belongs_to :director, class_name: "User", foreign_key: :director_id

	validates_presence_of :nombre, :director_id
end
