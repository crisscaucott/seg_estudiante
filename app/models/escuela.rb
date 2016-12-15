class Escuela < ActiveRecord::Base
	self.table_name = 'escuela'
	has_many :carreras, class_name: "Carrera"
	has_many :directores, class_name: "User", foreign_key: :escuela_id
	# belongs_to :director, class_name: "User", foreign_key: :director_id

	validates_presence_of :nombre

	def self.getEscuelas
		return self.select([:id, :nombre]).order(nombre: :asc).all
	end
end
