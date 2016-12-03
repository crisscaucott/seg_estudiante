namespace :desercion do

	desc "Llena la tabla de deserciones con los estados iniciales."
	task :fill_deserciones => :environment do
		# Truncar la tabla antes de insertar
		ActiveRecord::Base.connection.execute("TRUNCATE #{EstadoDesercion.table_name} RESTART IDENTITY")

		estados = [
			{nombre_estado: "Deserción Segura", notificar: false, riesgoso: false},
			{nombre_estado: "Alto Riesgo Deserción", notificar: false, riesgoso: false},
			{nombre_estado: "Medio Riesgo Deserción", notificar: false, riesgoso: false},
			{nombre_estado: "Alta Probabilidad de Retención", notificar: false, riesgoso: false},
			{nombre_estado: "Retención Segura", notificar: false, riesgoso: false},
			{nombre_estado: "Cambio de Carrera", notificar: false, riesgoso: false},
			{nombre_estado: "Desertó", notificar: false, riesgoso: false},
		]

		estados.each do |estado|
			estado_obj = EstadoDesercion.new(estado)
			estado_obj.save
		end
	end

end
