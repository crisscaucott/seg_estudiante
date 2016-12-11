class FichaEstudiante < ActiveRecord::Base
	self.table_name = 'ficha_estudiante'
	belongs_to :estudiante, class_name: "Estudiante", foreign_key: :estudiante_id
	belongs_to :tutor, class_name: "User", foreign_key: :tutor_id
	belongs_to :estado_desercion, class_name: "EstadoDesercion", foreign_key: :estado_desercion_id
	belongs_to :motivo_desercion, class_name: "MotivoDesercion", foreign_key: :motivo_desercion_id
	belongs_to :destino, class_name: "Destino", foreign_key: :destino_id

	validates_presence_of :estudiante_id, :tutor_id, :estado_desercion_id, :fecha_registro

	validate :checkFieldsExists
	validate :checkMotivoYDestino

	def checkFieldsExists
		if !self[:estudiante_id].nil?
			self.errors[:estudiante_id] << "Hubo un error en encontrar el estudiante seleccionado en el sistema." if !Estudiante.exists?(id: self[:estudiante_id])
		end

		if !self[:tutor_id].nil?
			self.errors[:tutor_id] << "Hubo un error en encontrar al tutor seleccionado en el sistema." if !User.exists?(id: self[:tutor_id])
		end

		if !self[:estado_desercion_id].nil?
			self.errors[:estado_desercion_id] << "Hubo un error en encontrar el estado de deserción seleccionado en el sistema." if !EstadoDesercion.exists?(id: self[:estado_desercion_id])
		end

		if !self[:motivo_desercion_id].nil?
			self.errors[:motivo_desercion_id] << "Hubo un error en encontrar el motivo de deserción seleccionado en el sistema." if !MotivoDesercion.exists?(id: self[:motivo_desercion_id])
		end

		if !self[:destino_id].nil?
			self.errors[:destino_id] << "Hubo un error en encontrar el destino seleccionado en el sistema." if !Destino.exists?(id: self[:destino_id])
		end
	end

	def checkMotivoYDestino
		if !self[:estado_desercion_id].nil? 
			estado_des_obj = EstadoDesercion.find_by(id: self[:estado_desercion_id])
			if estado_des_obj.riesgoso
				if self[:motivo_desercion_id].nil? || self[:destino_id].nil?
					self.errors[:motivo_destino_req] = "Debe seleccionar un motivo de deserción y destino."
				end
			else
				self[:motivo_desercion_id] = nil
				self[:destino_id] = nil
			end
		end

	end

end
