class Destino < ActiveRecord::Base

	def self.getDestinos
		return self.all.order(nombre: :asc)
	end
end
