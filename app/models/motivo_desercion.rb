class MotivoDesercion < ActiveRecord::Base
	self.table_name = 'motivo_desercion'

	def self.getMotivos
		return self.all.order(nombre: :asc)
	end
end
