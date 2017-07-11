namespace :app do

	desc "Task description"
	task :init_config => :environment do
		configs = [
			{
				alertas: {frec_alerta_id: nil, prox_envio: nil, fecha_config: nil, last_task_call: nil, last_error: nil}
			}
		]

		configs.each do |config|
			config_name = config.keys[0].to_s

			config_obj = ConfiguracionApp.find_by(nombre_config: config_name)

			if config_obj.nil?
				config_obj = ConfiguracionApp.new(nombre_config: config_name, atributos_config: config[config.keys[0]])

				if config_obj.save
					puts "Configuracion '#{config_name}' ingresado."
				else
					puts "Fallo '#{config_name}'."
				end
			else
				config_obj.atributos_config = config[config.keys[0]]
				config_obj.save
			end
		end

	end
end
