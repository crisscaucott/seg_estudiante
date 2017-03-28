namespace :asistencias do

	desc "Llena la tabla de estados de asistencias."
	task :fill_estados_asistencias => :environment do
		estados = [
			{nombre_estado: "Presente", estado_corto: "p"},
			{nombre_estado: "Retrasado", estado_corto: "r"},
			{nombre_estado: "Falta justificada", estado_corto: "j"},
			{nombre_estado: "Falta injustificada", estado_corto: "i"},
			{nombre_estado: "Ausente", estado_corto: "a"},
		]
		estados_count = EstadosAsistencia.all.count

		if estados.size != estados_count
			# Se agregan los estados.
			estados.each do |e|
				if EstadosAsistencia.new(e).save
					puts "Estado de asistencia '#{e[:nombre_estado]}' ingresado existosamente."
				else
					puts "Hubo un problema en ingresar el estado de asistencia '#{e[:nombre_estado]}'"
				end
			end

		else
			# No se agregan porque existen la misma cantidad de estados en la BD que en al array.
			
		end
	end

end
