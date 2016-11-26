class LogCargaMasiva < ActiveRecord::Base
	self.table_name = 'log_carga_masiva'

	def uploadAssistance()
		spreadsheet = openSpreadsheet(Rails.root.join(self.url_archivo))
		req_data = {asignatura: nil}
		header_assis = nil
		response = {error: false, msg: nil}
		assis_detail = {success: 0, failed: 0, est_not_found: 0, total: 0}

		(1..spreadsheet.last_row).each do |ss_row|
			# Fila 'curso'
			if spreadsheet.row(ss_row)[0] =~ /curso/i
				asig_match = /\[.*\]/.match(spreadsheet.row(ss_row)[1])
				if !asig_match.nil?
					asig_code = asig_match[0].gsub(/(\[|\]|\s)/, '').strip
					req_data[:asignatura] = Asignatura.select(:id).where(codigo: asig_code).first

					if req_data[:asignatura].nil?
						# Si no se encontro la asignatura, se deja de leer el excel.
						response[:error] = true
						response[:msg] = "Hubo problema en encontrar la asignatura del excel."
						break
					end

				else
					# No encontro el codigo por regex

				end					
			end # END if curso

			# Desde aqui empieza la fila de cada estudiante con su asistencia.
			if !header_assis.nil?
				# Para de leer el excel si ya no hay mas estudiantes.
				break if spreadsheet.row(ss_row)[0].nil?

				assis_detail[:total] += 1 # Se cuenta 1 alumno mas al total.
				assis_hash = Hash[[header_assis, spreadsheet.row(ss_row)].transpose]

				estudiante_obj = Estudiante.getIdEstudianteByCarreraAndRut(assis_hash[:"nombre de usuario"].to_i, req_data[:asignatura].id)

				# Se cambia a false, si hay problema en actualizar o ingresar 
				# con alguna de las asistencias del estudiante.
				pass = true
				if !estudiante_obj.nil?
					# Se encontro al estudiante en la BD.
					# Recorrer los campos del estudiante
					assis_hash.each do |assis_field, assis_value|
						# Solamente tomar los campos que son de fecha.
						if assis_field =~ /[0-9]+\.[0-9]+\.[0-9]+/
							fecha_assis = formatDateTime(assis_field)
							assis_value = assis_value.strip.downcase
							assis_obj = Asistencia.select([:id, :valor_asistencia]).where(asignatura_id: req_data[:asignatura].id).where(estudiante_id: estudiante_obj.id).where(fecha_asistida: fecha_assis).first

							if assis_obj.nil?
								# Si no existe el registro de asistencia para el alumno x cursando la asignatura x en la fecha x, 
								# se ingresa como una nueva asistencia a la BD.
								assis_obj = Asistencia.new(
									asignatura_id: req_data[:asignatura].id,
									estudiante_id: estudiante_obj.id,
									fecha_asistida: fecha_assis,
									valor_asistencia: assis_value
								)

								if assis_obj.save
									# Se ingreso la asistencia exitosamente.
									puts "SE INGRESO ASISTENCIA ID: #{assis_obj.id} para estudiante: #{estudiante_obj.id}".green

								else
									# Fallo el ingreso de la asistencia.
									puts "FALLO INGRESO ASISTENCIA PARA ESTUDIANTE: #{estudiante_obj.id}".green
									pass = false
								end

							else
								# Sino, se actualiza el valor de la asistencia.
								assis_obj.valor_asistencia = assis_value
								if assis_obj.save!
									# Se actualiza la asistencia exitosamente.
									puts "SE ACTUALIZA ASISTENCIA ID: #{assis_obj.id} para estudiante: #{estudiante_obj.id}".green

								else
									# Hubo un error al actualizar la asistencia.
									puts "FALLO ACTUALIZACION DE ASISTENCIA para estudiante: #{estudiante_obj.id}".green
									pass = false
								end
							end

						end # END assis_field regex
					end # assis_hash.each

					# Contar si el estidiante no tuvo algun problema en ingresar-actualizar su asistencia.
					if pass
						assis_detail[:success] += 1
					else
						assis_detail[:failed] += 1
					end

				else
					# No se encontro al estudiante en la BD.
					assis_detail[:est_not_found] += 1
				end # END estudiante_obj.nil?
				
			end

			# Fila cabecera de las asistencias
			if spreadsheet.row(ss_row)[0] =~ /id\s+de(l)?\s+estudiante/i
				header_assis = spreadsheet.row(ss_row).map{|hn| hn.downcase.strip.to_sym }
			end
		end # END spreadsheet.each

		if !response[:error]
			# Si no hay errores, se registra la carga masiva del usuario.
			self.tipo_carga = 'asistencia'
			self.detalle = assis_detail
			self.save
		end

		return response
	end

	def self.readExcelFile(file, user_id)
		spreadsheet = open_spreadsheet(file)
		response = {error: false, msg: nil}

	  # BUSCAR LA ASIGNATURA EN LA BD.
	  asignatura_name = spreadsheet.row(1)[2].gsub(/\[.*\]\p{Space}*/, '')
	  asignatura_obj = Asignatura.select([:id, :nombre]).where(nombre: asignatura_name.downcase).where(fecha_borrado: nil).first

	  begin
		  # PERIODO ACADEMICO
		  pa_splitted = spreadsheet.row(3)[2].split('-')
		  if pa_splitted[1] == '01'
		  	periodo_academico = DateTime.parse("#{pa_splitted[0]}-01-01")
		  elsif pa_splitted[1] == '02'
		  	periodo_academico = DateTime.parse("#{pa_splitted[0]}-07-01")
		  else
		  	periodo_academico = nil
		  end

		  # PONDERACION NOTAS
		  pn_str = spreadsheet.row(6)[2].strip
		  matches = /FACING\s*(.*)\+/.match(pn_str)
		  matches2 = /\(.*\)/.match(matches[1]) # ponderaciones de cada nota
		  ponderaciones_catedra = matches2[0].gsub(/\s|\(|\)/, '').split('+') # quitar parentesis y espacios y pasar cada ponderacion como un array

		  ponderaciones_hash = {}
		  if ponderaciones_catedra.present?
		  	ponderaciones_catedra.each do |pc|
		  		aux = pc.split('*')
		  		ponderaciones_hash[aux[0].to_s.downcase.to_sym] = aux[1].to_i
		  	end
			  # PONDERACION TOTAL DE LAS NOTAS DE LA CATEDRA
		  	ponderaciones_hash[:catedra] = /[0-9]+\%?\s*$/.match(matches[1].strip)[0].to_i
		  end

		  # PONDERACION DE LAB
		  ponderaciones_lab =  /lab(.*)%/i.match(pn_str)
		  if ponderaciones_lab.present?
		  	ponderaciones_hash[:lab] = ponderaciones_lab[0].split('*')[1].to_i
		  end
	  rescue StandardError => e
	  	puts e
	  	response[:error] = true
	  	response[:msg] = "Hubo un error con el formato del excel subido."
	  	return response
	  end

	  notas_fields_count = 0
	  header_notas_found = false
	  header_notas = {}
	  notas_row_found = false
	  estudiante_header = {}

	  # VALIDAR PONDERACIONES, ASIGNTAURA Y OTRAS COSAS ANTS DE LEER EL EXCEL...

	  if(!asignatura_obj.nil? && !periodo_academico.nil? && ponderaciones_hash.present?)
		  (1..spreadsheet.last_row).each do |ss_row|
		    # Cada fila del estudiante.
		    if notas_row_found
		    	puts spreadsheet.row(ss_row)[0]
		    	# byebug
		    	break if spreadsheet.row(ss_row)[0].nil?
		    	# Se crea un hash con las notas del estudiante.
		    	# {:n1=>nil, :n2=>nil, :n3=>nil, :oa=>nil, :prom=>nil, :plab=>nil, :np=>nil, :ex=>nil}
		    	notas_alumno_hash = Hash[[header_notas, spreadsheet.row(ss_row)[5...(5 + notas_fields_count)]].transpose]
		    	row_hash = Hash[[estudiante_header, spreadsheet.row(ss_row)].transpose]

		    	carrera_obj = Carrera.select(:id).where(plan: row_hash[:plan].strip.downcase).first
		    	estudiante_obj = Estudiante.select(:id).where(rut: row_hash[:dni].to_s.strip).where(carrera_id: carrera_obj.id).first

		    	if !estudiante_obj.nil?
		    		# Estudiante encontrado en la BD

		    		# Hacer calzar SOLO las notas parciales, entre la fila de cada estudiante con el hash de las ponderaciones de las notas (ponderaciones_hash)
		    		ponderaciones_hash.each do |tipo_nota, ponderacion|
		    			nota = notas_alumno_hash[tipo_nota]

		    			# Si la nota esta seteada en el excel,
		    			# solo deberian calzar las notas 'n' y las 'oa'
		    			if !nota.nil?
		    				# Primero consultar si la nota del alumno ya existe en la BD,
		    				# si existe, se actualiza la nota al alumno, sino se ingresa.
		    				calificacion_obj = Calificacion.select([:id, :valor_calificacion]).where(estudiante_id: estudiante_obj.id).where(asignatura_id: asignatura_obj.id).where(nombre_calificacion: tipo_nota).where(periodo_academico: periodo_academico).first

		    				if calificacion_obj.nil?
		    					puts "NOTA NUEVA"
		    					# Se ingresa como una nueva calificacion
			    				calificacion_obj = Calificacion.new({
			    					estudiante_id: estudiante_obj.id,
			    					asignatura_id: asignatura_obj.id,
			    					valor_calificacion: nota,
			    					nombre_calificacion: tipo_nota,
			    					ponderacion: ponderacion,
			    					periodo_academico: periodo_academico
			    				})

			    				if calificacion_obj.save
			    					# Se ingreso la calificacion con exito
			    					puts "ingreso exitoso id: #{calificacion_obj.id}"
			    				else
			    					# Fallo el ingreso
			    					puts "ingreso NO exitoso"
			    					
			    				end

		    				else
		    					puts "SE ACTUALIZA NOTA id: #{calificacion_obj.id}"

		    					# Se actualiza el valor de la calificacion
		    					calificacion_obj.valor_calificacion = nota
		    					calificacion_obj.save!
		    					
		    				end # END calificacion_obj.nil?
		    			end # END !nota.nil?
		    		end # END ponderaciones_hash.each

		    	else
		    		# Estudiante no encontrado en la BD
		    		
		    	end
		    end # END notas_row_found

		    # Armar el array de la cabecera de las notas, una vez que se haya encontrado.
		    if header_notas_found && !header_notas.present?
		    	header_notas = spreadsheet.row(ss_row)[5...(5 + notas_fields_count)].map{|hn| hn.downcase.to_sym }
		    	notas_row_found = true
		    end

		    # Cuando se encuentra la fila cabecera de las notas, se cuenta cuantas columnas del excel hay para las notas (N1	N2	N3	OA	PROM	PLAB	NP	EX).
		    if spreadsheet.row(ss_row)[0] =~ /nro(\.)?/i
		    	# Se guarda un array con todas las columnas del estudiante del excel.
		    	# [:nro, :dni, :nombre, :plan, :expediente, :notasparciales, nil, nil, nil, nil, nil, nil, nil, :definitiva, :calificaci_n]
		    	estudiante_header = spreadsheet.row(ss_row).map{|eh| eh.gsub(/\.|\s/, '').downcase.to_sym if !eh.nil?}
		    	begin_to_count = false
		    	spreadsheet.row(ss_row).each do |notas_header|
		    		if notas_header =~ /notas\s+parciales/i
		    			notas_fields_count += 1
		    			begin_to_count = true
		    		end
		    		notas_fields_count += 1 if begin_to_count && notas_header.nil?
		    	end

		    	header_notas_found = true
		    end
		  end # END excel
		  response[:msg] = "Notas subidas exitosamente."

		else
			response[:error] = true
			response[:msg] = "Hubo un error con el formato del excel subido."
	  end
		# END validaciones

		if !response[:error]
			# Si no hay errores, se registra la carga masiva del usuario.
			carga_masiva_obj = self.new({usuario_id: user_id, tipo_carga: 'excel'})
			carga_masiva_obj.save			
		end

		return response
	end

	def openSpreadsheet(file)
	  case file.extname
		  when '.csv' then Roo::Csv.new(file.realpath, packed: false, file_warning: :ignore)
		  when '.xls' then Roo::Excel.new(file.realpath, packed: false, file_warning: :ignore)
		  when '.xlsx' then Roo::Excelx.new(file.realpath, packed: false, file_warning: :ignore)
		  else raise "Unknown file type: #{file.original_filename}"
	  end
	end

	def formatDateTime(date_time_str)
		date_time = {year: nil, month: nil, day: nil, hour: nil, min: nil}
		# aux[0] => dd.mm.aaaa, aux[1] => hh:mm
		aux = date_time_str.to_s.split(' ')
		# Fecha
		date_aux = aux[0].split(/\.|\-|\//)
		date_time[:year] = date_aux[2]
		date_time[:month] = date_aux[1]
		date_time[:day] = date_aux[0]
		# Tiempo
		time_aux = aux[1].split(/\.|\:/)
		date_time[:hour] = time_aux[0]
		date_time[:min] = time_aux[1]
		
		return DateTime.parse("#{date_time[:day]}.#{date_time[:month]}.#{date_time[:year]} #{date_time[:hour]}:#{date_time[:min]}")
	end

end
