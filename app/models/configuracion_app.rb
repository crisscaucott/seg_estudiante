class ConfiguracionApp < ActiveRecord::Base
	self.table_name = :configuracion_app

	def self.getAlertaConfig
		return self.find_by(nombre_config: 'alertas')
	end
end
