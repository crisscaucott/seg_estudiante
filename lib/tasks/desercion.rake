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
			# {nombre_estado: "Cambio de Carrera", notificar: false, riesgoso: false},
			{nombre_estado: EstadoDesercion::DESERTO_ESTADO, notificar: false, riesgoso: true},
			{nombre_estado: EstadoDesercion::DESERTO_NINGUNO, notificar: false, riesgoso: false},
		]

		estados.each do |estado|
			estado_obj = EstadoDesercion.new(estado)
			estado_obj.save
		end
	end

	desc "Llena la tabla de motivos de deserciones con sus tipos."
	task :fill_motivos_desercion => :environment do
		ActiveRecord::Base.connection.execute("TRUNCATE #{MotivoDesercion.table_name} RESTART IDENTITY")
		motivos = [
			{nombre: "Economico"},
			{nombre: "Academico"},
			{nombre: "Vocacional"},
			{nombre: "Familiar"},
			{nombre: "Personal"},
			{nombre: "Otro"}
		]

		motivos.each do |m|
			MotivoDesercion.new(m).save
		end
	end

	desc "Llena la tabla de motivos de deserciones con sus tipos."
	task :fill_destinos => :environment do
		ActiveRecord::Base.connection.execute("TRUNCATE #{Destino.table_name} RESTART IDENTITY")
		destinos = [
			{nombre: "CC-FING"},
			{nombre: "CC-UCEN"},
			{nombre: "Otra universidad"},
			{nombre: "Trabajo"},
			{nombre: "Otro"}
		]

		destinos.each do |m|
			Destino.new(m).save
		end
	end

end
