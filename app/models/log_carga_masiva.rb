class LogCargaMasiva < ActiveRecord::Base
	self.table_name = 'log_carga_masiva'
	belongs_to :usuario, class_name: "User", foreign_key: :usuario_id

	def uploadAssistance(carrera_id)
		spreadsheet = openSpreadsheet(Rails.root.join(self.url_archivo))
		req_data = {asignatura: nil, ids_carreras: nil}
		header_assis = nil
		response = {error: false, msg: nil}
		assis_detail = {success: 0, failed: 0, est_not_found: 0, total: 0, est_multiple: 0}
		estados_asistencia = EstadosAsistencia.all

		(1..spreadsheet.last_row).each do |ss_row|
			# Fila 'curso'
			if spreadsheet.row(ss_row)[0] =~ /curso/i
				asig_match = /[0-9]+/.match(spreadsheet.row(ss_row)[1].strip)

				if !asig_match.nil?
					# Encontro el codigo de la asignatura en el excel.
					asig_code = asig_match[0].strip
					req_data[:asignatura] = Asignatura.select(:id).where(codigo: asig_code).where(fecha_borrado: nil).first

					if req_data[:asignatura].nil?
						# Si no se encontro la asignatura, se deja de leer el excel.
						response[:error] = true
						response[:msg] = "Hubo problema en encontrar la asignatura del excel."
						break
					end

				else
					# No encontro el codigo por regex, se intentara buscar la asignatura por su nombre (caso no ideal).
					asig_name = spreadsheet.row(ss_row)[1].gsub(/\-(.*)/, '').downcase.strip
					req_data[:asignatura] = Asignatura.select(:id).where(nombre_formateado: asig_name).where(fecha_borrado: nil).first

					if req_data[:asignatura].nil?
						# Si no se encontro la asignatura, se deja de leer el excel.
						response[:error] = true
						response[:msg] = "Hubo problema en encontrar la asignatura del excel."
						break
					end
				end

				# Guardar los ids de las carreras que pertenece la asignatura encontrada,
				# esto es util para encontrar a que carrera pertenece cada alumno leido.
				# Para que todo funcione, debe existir la relacion entre carrera y asignatura, osea debe estar la fila en la tabla 'asignatura-carrera'.
				# req_data[:ids_carreras] = req_data[:asignatura].carrera_ids

			end # END if curso

			# Desde aqui empieza la fila de cada estudiante con su asistencia.
			if !header_assis.nil?
				# Para de leer el excel si ya no hay mas estudiantes.
				break if spreadsheet.row(ss_row)[0].nil?

				assis_detail[:total] += 1 # Se cuenta 1 alumno mas al total.
				assis_hash = Hash[[header_assis, spreadsheet.row(ss_row)].transpose]

				# Se agrega la condicion si el estudiante tiene uno de los ids de carreras asociado a la asignatura, en caso de que el estudiante este varias veces en la BD pero en distintas carreras.
				# estudiante_obj = Estudiante.select(:id).where(rut: assis_hash[:"nombre de usuario"].to_i.to_s).where(fecha_eliminacion: nil).where(carrera_id: req_data[:ids_carreras])
				estudiante_obj = Estudiante.select(:id).where(rut: assis_hash[:"nombre de usuario"].to_i.to_s).where(fecha_eliminacion: nil).where(carrera_id: carrera_id)

				if estudiante_obj.size > 1
					# Hay mas de 1 estudiante activo cursando algunas de las carreras asociadas a la asignatura, no se sube su asitencia (mal).
					estudiante_obj = nil
					assis_detail[:est_multiple] += 1
					puts "SE ENCONTRO MAS DE 1 ESTUDIANTE"
				elsif estudiante_obj.size == 1
					# Solo se encontro 1 estudiante (bien).
					estudiante_obj = estudiante_obj[0]
				end

				# Se cambia a false, si hay problema en actualizar o ingresar 
				# con alguna de las asistencias del estudiante.
				pass = true
				if estudiante_obj.present?
					# Se encontro al estudiante en la BD.
					# Recorrer los campos del estudiante
					assis_hash.each do |assis_field, assis_value|
						# Solamente tomar los campos que son de fecha.
						if assis_field =~ /[0-9]+\.[0-9]+\.[0-9]+/
							fecha_assis = formatDateTime(assis_field)
							assis_value = assis_value.strip.downcase
							assis_obj = Asistencia.select([:id, :valor_asistencia]).where(asignatura_id: req_data[:asignatura].id).where(estudiante_id: estudiante_obj.id).where(fecha_asistida: fecha_assis).first

							# Se busca el objeto en el array de estados de asistencia.
							estado_assis_obj = nil
							estados_asistencia.each do |ea|
								if ea.estado_corto == assis_value
									estado_assis_obj = ea
									break
								end
							end

							# Si el valor de la asistencia no esta en la BD, se deja como ausente.
							if estado_assis_obj.nil?
								estados_asistencia.each do |ea|
									if ea.estado_corto == "a"
										estado_assis_obj = ea
										break
									end
								end								
							end

							if assis_obj.nil?
								# Si no existe el registro de asistencia para el alumno x cursando la asignatura x en la fecha x, 
								# se ingresa como una nueva asistencia a la BD.
								assis_obj = Asistencia.new(
									asignatura_id: req_data[:asignatura].id,
									estudiante_id: estudiante_obj.id,
									fecha_asistida: fecha_assis,
									estado_asistencia_id: estado_assis_obj.id
								)

								if assis_obj.save
									# Se ingreso la asistencia exitosamente.
									puts "SE INGRESO ASISTENCIA ID: #{assis_obj.id} para estudiante: #{estudiante_obj.id}"

								else
									# Fallo el ingreso de la asistencia.
									puts "FALLO INGRESO ASISTENCIA PARA ESTUDIANTE: #{estudiante_obj.id}"
									pass = false
								end

							else
								# Si existe en la BD, se actualiza el estado de la asistencia.
								assis_obj.estado_asistencia_id = estado_assis_obj.id
								
								if assis_obj.save
									# Se actualiza la asistencia exitosamente.
									puts "SE ACTUALIZA ASISTENCIA ID: #{assis_obj.id} para estudiante: #{estudiante_obj.id}"

								else
									# Hubo un error al actualizar la asistencia.
									puts "FALLO ACTUALIZACION DE ASISTENCIA para estudiante: #{estudiante_obj.id}"
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

		  response[:msg] = assis_detail
		end

		return response
	end

	def uploadNotas()
		spreadsheet = openSpreadsheet(Rails.root.join(self.url_archivo))
		response = {error: false, msg: nil}
		detalle = {est_not_found: 0, est_found: 0, total: 0, new_notas: 0, upd_notas: 0, failed_notas: 0}
		asignatura_obj = nil

	  # BUSCAR LA ASIGNATURA EN LA BD.
	  codigo_cell = /\[.*\]/.match(spreadsheet.row(1)[2])
	  if !codigo_cell.nil?
	  	# Existe codigo en la celda.
	  	# Se busca la asignatura por su codigo.
	  	asignatura_codigo = codigo_cell[0].gsub(/(\[|\]|\s)/, '')
			asignatura_obj = Asignatura.select(:id).where(codigo: asignatura_codigo).where(fecha_borrado: nil).first

	  else
	  	# No existe codigo en la celda.
	  	# Se busca la asignatura por su nombre.
		  asignatura_name = Asignatura.new(nombre: spreadsheet.row(1)[2].gsub(/\[.*\]\p{Space}*/, '')).nombre_formateado
		  asignatura_obj = Asignatura.select([:id, :nombre]).where(nombre_formateado: asignatura_name).where(fecha_borrado: nil).first
	  end

	  # Si no se encuentra la asignatura, se crea en base a su codigo y nombre.
	  # if asignatura_obj.nil?
	  # 	asignatura_obj = Asignatura.new(
	  # 		nombre: asignatura_name.strip.capitalize,
	  # 		codigo: asignatura_codigo,
	  # 		creditos: 0
	  # 	)
	  # 	asignatura_obj.save
	  # end

	  if !asignatura_obj.nil?
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
			    	detalle[:total] += 1
			    	# Se crea un hash con las notas del estudiante.
			    	# {:n1=>nil, :n2=>nil, :n3=>nil, :oa=>nil, :prom=>nil, :plab=>nil, :np=>nil, :ex=>nil}
			    	notas_alumno_hash = Hash[[header_notas, spreadsheet.row(ss_row)[5...(5 + notas_fields_count)]].transpose]
			    	row_hash = Hash[[estudiante_header, spreadsheet.row(ss_row)].transpose]

			    	carrera_obj = Carrera.select(:id).where(codigo: row_hash[:plan]).first

			    	if !carrera_obj.nil?
			    		estudiante_obj = Estudiante.select(:id).where(rut: row_hash[:dni].to_s.strip).where(carrera_id: carrera_obj.id).first

				    	if !estudiante_obj.nil?
				    		detalle[:est_found] += 1
				    		# Estudiante encontrado en la BD

				    		# Hacer calzar SOLO las notas parciales, entre la fila de cada estudiante con el hash de las ponderaciones de las notas (ponderaciones_hash)
				    		ponderaciones_hash.each do |tipo_nota, ponderacion|
				    			nota = notas_alumno_hash[tipo_nota]

				    			# Si la nota esta seteada en el excel,
				    			# solo deberian calzar las notas 'n' y las 'oa'
				    			if !nota.nil?
				    				# Primero consultar si la nota del alumno ya existe en la BD,
				    				# si existe, se actualiza la nota al alumno, sino se ingresa.
				    				calificacion_obj = Calificacion.where(estudiante_id: estudiante_obj.id).where(asignatura_id: asignatura_obj.id).where(nombre_calificacion: tipo_nota).where(periodo_academico: periodo_academico).first

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
					    					detalle[:new_notas] += 1
					    				else
					    					# Fallo el ingreso
					    					puts "ingreso NO exitoso"
					    					detalle[:failed_notas] += 1
					    					
					    				end

				    				else
				    					puts "SE ACTUALIZA NOTA id: #{calificacion_obj.id}"

				    					# Se actualiza el valor de la calificacion
				    					calificacion_obj.valor_calificacion = nota
				    					if calificacion_obj.save
				    						detalle[:upd_notas] += 1
				    					else
					    					detalle[:failed_notas] += 1
				    						
				    					end
				    				end # END calificacion_obj.nil?
				    			else
				    				# Como no hay valor para este tipo de nota (n1, n2) se consulta en la BD si existe para borrarlo.
				    				calificacion_obj = Calificacion.select(:id).find_by(estudiante_id: estudiante_obj.id, asignatura_id: asignatura_obj.id, periodo_academico: periodo_academico, nombre_calificacion: tipo_nota)

				    				if !calificacion_obj.nil?
				    					# Existe este tipo de nota en la BD, se elimina.
				    					calificacion_obj.delete
				    				end

				    			end # END !nota.nil?
				    		end # END ponderaciones_hash.each

				    	else
				    		# Estudiante no encontrado en la BD
				    		detalle[:est_not_found] += 1

				    	end
			    	else
			    		detalle[:est_not_found] += 1
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
	  else
	  	response[:error] = true
	  	response[:msg] = "Hubo un error en encontrar la asignatura del excel en el sistema."
	  end # !asignatura_obj.nil?


		if !response[:error]
			# Si no hay errores, se registra la carga masiva del usuario.
			self.tipo_carga = 'excel'
			self.detalle = detalle
			self.save

			response[:msg] = detalle
		end

		return response
	end

	def uploadEstudiantes
		spreadsheet = openSpreadsheet(Rails.root.join(self.url_archivo))
		response = {error: false, msg: nil}
		header = spreadsheet.row(1).map{|h| h.gsub(/ñ/i, 'n').downcase.to_sym }
		estado_desercion_obj = EstadoDesercion.select(:id).find_by(nombre_estado: EstadoDesercion::DESERTO_NINGUNO)
		est_detail = {total: 0, new: [], upd: [], failed: []}

		# Se verifica que el estado de desercion 'ninguno' exista.
		if estado_desercion_obj.nil?
			response[:error] = true
			response[:msg] = "Error interno"
			return response
		end

		(2..spreadsheet.last_row).each do |ss_row|
			if !spreadsheet.row(ss_row)[0].nil?
				est_detail[:total] += 1

				row_hash = Hash[[header, spreadsheet.row(ss_row)].transpose]
				carrera_obj = Carrera.select(:id).find_by(codigo: row_hash[:codigo_carrera_sig21].strip, fecha_eliminacion: nil)

				est_hash = {
					nombre: row_hash[:nombres],
					apellido: row_hash[:a_paterno] + " " + row_hash[:a_materno],
					rut: row_hash[:rut].to_i.to_s.strip,
					dv: row_hash[:dv].to_s.strip,
					# fecha_ingreso: formatPeriodoAcademico(row_hash[:periodo_academico].to_i.to_s),
					fecha_ingreso: row_hash[:fecha_matricula],
					carrera_id: carrera_obj.nil? ? nil : carrera_obj.id,
					estado_desercion_id: estado_desercion_obj.id # Todos los estudiantes se inicializan con estado de desercion "ninguno".
				}

				info_est_hash = {
					anio_matricula: row_hash[:ano_matricula],
					fecha_matricula: row_hash[:fecha_matricula],
					sede: row_hash[:sede],
					situacion: row_hash[:situacion],
					sexo: row_hash[:sexo].downcase,
					nacionalidad: row_hash[:nacionalidad_tabla_clientes],
					fecha_nacimiento: row_hash[:fecha_nacimiento],
					direccion: row_hash[:direccion],
					comuna: row_hash[:comuna],
					telefono_fijo: row_hash[:telefono_fijo],
					telefono_movil: row_hash[:telefono_movil],
					correo_google_ucen: row_hash[:correo_google_ucen],
					codigo_colegio: row_hash[:codigo_colegio],
					nombre_colegio: row_hash[:nombre_colegio],
					tipo_colegio: row_hash[:tipo_colegio],
					tipo_ensenanza: row_hash[:tipo_ensenanza],
					comuna_colegio: row_hash[:comuna_colegio],
					region_colegio: row_hash[:region_colegio],
					anio_egreso: row_hash[:ano_egreso],
					tipo_ingreso: row_hash[:tipo_ingreso],
					anio_psu_ingreso: row_hash[:ano_psu_ingreso],
					nota_nem_ingreso: row_hash[:nota_nem_ingreso],
					psu_lenguaje: row_hash[:puntaje_leng_ingreso],
					psu_matematica: row_hash[:puntaje_mat_ingreso],
					psu_historia: row_hash[:puntaje_cs_soc_hist_ingreso],
					psu_ciencias: row_hash[:puntaje_ciencias_ingreso],
					puntaje_nem_ingreso: row_hash[:puntaje_nem_ingreso],
					puntaje_pond_ingreso: row_hash[:puntaje_ponderado_ingreso],
					tipo_programa: row_hash[:"tipo programa"],
					facultad: row_hash[:facultad],
					jornada: row_hash[:jornada],
				}


				# Se tiene que encontrar la carrera primero
				if !carrera_obj.nil?
					# Intentar capturar cualquier tipo de excepcion con el manejo de la informacion del estudiante para evitar detener el proceso.
					begin
						# Verificar si el estudiante ya esta en la bd.
						estudiante_obj = Estudiante.where(rut: est_hash[:rut]).where(dv: est_hash[:dv]).where(carrera_id: est_hash[:carrera_id]).first

						if !estudiante_obj.nil?
							# Esta en la BD, se pasa a actualizar los datos basicos del estudiante.
							# Luego se actualiza los datos extra del estudiante.
							if !estudiante_obj.info_estudiante.nil?
								estudiante_obj.info_estudiante.update_attributes(info_est_hash)
							else
								info_estudiante_obj = InfoEstudiante.new(info_est_hash)
								estudiante_obj.info_estudiante = info_estudiante_obj
							end


							if estudiante_obj.valid?
								puts "Estudiante encontrado valido"
								est_detail[:upd] << estudiante_obj.rut + "-" + estudiante_obj.dv
								estudiante_obj.save

							else
								puts "Estudiante encontrado no valido"
								est_detail[:failed] << estudiante_obj.rut + "-" + estudiante_obj.dv
								
							end

						else
							# No esta en la BD, se agrega como nuevo.
							estudiante_obj = Estudiante.new(est_hash)
							info_estudiante_obj = InfoEstudiante.new(info_est_hash)
							estudiante_obj.info_estudiante = info_estudiante_obj

							if estudiante_obj.valid?
								# Cumple con todas las validaciones.
								puts "Estudiante nuevo valido"
								estudiante_obj.save
								est_detail[:new] << estudiante_obj.rut + "-" + estudiante_obj.dv

							else
								# No cumple.
								puts "Estudiante nuevo no valido"
								est_detail[:failed] << estudiante_obj.rut + "-" + estudiante_obj.dv
								
							end
						end

					rescue StandardError => e
						# Hubo un problema inesperado con este estudiante.
						est_detail[:failed] << est_hash[:rut] + "-" + est_hash[:dv]

					end
				else
					# No se encontro la carrera.
					est_detail[:failed] << est_hash[:rut] + "-" + est_hash[:dv]

				end
			end # END if [0].nil?
		end # END EXCEL each.

		if !response[:error]
			self.tipo_carga = "estudiante"
			self.detalle = est_detail
			self.save

			response[:msg] = est_detail
		end

		return response
	end

	def uploadPerfiles
		spreadsheet = openSpreadsheet(Rails.root.join(self.url_archivo))
		response = {error: false, msg: nil}
		detalle = {new: 0, total: 0, upd: 0, not_found: 0}

		begin
			header = spreadsheet.row(1).map{|h| h.gsub(/ñ/i, 'n').downcase.to_sym if !h.nil? }

			estilos_header_since = 0
			estilos_header_until = 0
			pass = false
			spreadsheet.row(1).each_with_index do |r, index|
				if r =~ /honey/i
					pass = true
					estilos_header_since = index
					estilos_header_until += 1
				elsif r =~ /vark/i
					pass = true
					estilos_header_since = index if estilos_header_since == 0
					estilos_header_until += 1
				end

				if pass && r.nil?
					estilos_header_until += 1
				end
			end

			estilos_header = spreadsheet.row(2)[estilos_header_since...(estilos_header_since + estilos_header_until)].map{|hn| hn.downcase.to_sym }

			(3..spreadsheet.last_row).each do |ss_row|
				# Para de leer el excel si encuentra una fila nula.
				break if spreadsheet.row(ss_row)[0].nil?
				detalle[:total] += 1
				# {:a=>8, :r=>15, :t=>15, :p=>11, :v=>nil, :au=>nil, :"l/e"=>nil, :k=>nil}
				estilos_hash = Hash[[estilos_header, spreadsheet.row(ss_row)[estilos_header_since...(estilos_header_since + estilos_header_until)]].transpose]
				# {:"nro."=>1, :dni=>13850352, :nombre=>"ALDUNATE MENGUAL, JAVIER IGNACIO", :plan=>"IC04", :expediente=>462, :"estilos honey"=>8, nil=>nil, :"estilos vark"=>nil, :definitiva=>nil, :calificaci_n=>nil}
				row_hash = Hash[[header, spreadsheet.row(ss_row)].transpose]

				carrera_obj = Carrera.select(:id).where(codigo: row_hash[:plan].strip).where(fecha_eliminacion: nil).first

				if !carrera_obj.nil?
					estudiante_obj = Estudiante.select(:id).where(rut: row_hash[:dni].to_s.strip).where(carrera_id: carrera_obj.id).first

					if !estudiante_obj.nil?
						# Revisar en la BD si ya existe el estilo de aprendizaje del alumno x.
						estilos_obj = EstilosAprendizaje.find_by(estudiante_id: estudiante_obj.id)

						estilos_data = {
							estudiante_id: estudiante_obj.id,
							honey_activo: estilos_hash[:a],
							honey_reflexivo: estilos_hash[:r],
							honey_teorico: estilos_hash[:t],
							honey_practico: estilos_hash[:p],
							vark_visual: estilos_hash[:v],
							vark_auditivo: estilos_hash[:au],
							vark_le: estilos_hash[:"l/e"],
							vark_kinestesico: estilos_hash[:k]
						}

						if estilos_obj.nil?
							# Se crea.
							estilos_obj = EstilosAprendizaje.new(estilos_data)

							if estilos_obj.valid?
								estilos_obj.save
								detalle[:new] += 1

							else
								puts "ALGO FALLO AL GUARDAR EL ESTILO DE APRENDIZAJE"
								
							end

						else
							# Se actualiza.
							estilos_obj.assign_attributes(estilos_data)
							if estilos_obj.valid?
								estilos_obj.save
								detalle[:upd] += 1

							else
								puts "ALGO FALLO AL ACTUALIZAR EL ESTILO DE APRENDIZAJE"
								
							end
							
						end

					else
						detalle[:not_found] += 1
						puts "NO SE ENCONTRO ESTUDIANTE"

					end

				else
					detalle[:not_found] += 1
					puts "NO SE ENCONTRO LA CARRERA, PLAN: #{row_hash[:plan]}"
					
				end
			end # END EXCEL
		rescue StandardError => e
			puts e
			puts e.backtrace
			# byebug
			response[:error] = true
			response[:msg] = "Ha ocurrido un error al leer el excel."
		end

		if !response[:error]
			# Si no hay errores, se registra la carga masiva del usuario.
			self.tipo_carga = 'estilos_aprendizaje'
			self.detalle = detalle
			self.save
			response[:msg] = detalle
		end

		return response
	end

	def uploadCarreraAsignaturas(escuela_id)
		spreadsheet = openSpreadsheet(Rails.root.join(self.url_archivo))
		response = {error: false, msg: nil}
		detail = {asignaturas_inserted: 0, asignaturas_failed: 0, asignaturas_found: 0, carrera_inserted: nil}

		begin
			# ENCONTRAR DURACION FORMAL DE LA CARRERA
			spreadsheet.sheet("Malla General")
			carrera_duracion = 0

			(1..spreadsheet.last_row).each do |row_num|
				# Por cada fila del excel, se intenta crear un array que contenga con la palabra 'semestre' en sus celdas.
				semestres_arr = spreadsheet.row(row_num).grep(/semestre/i)
				if semestres_arr.count != 0
					carrera_duracion = semestres_arr.count
					break
				end
			end

			# FIN ENCONTRAR DURACION FORMAL DE LA CARRERA
			if carrera_duracion != 0
				# Se encontro la duracion de la carrera.
				# Seleccionar la hoja con la carrera y las asignaturas.
				spreadsheet.sheet("PLAN DE ESTUDIOS")

				# El nombre de la carrera del excel.
				carrera_cell = spreadsheet.row(6)[2]

				if !carrera_cell.nil?
					# Se encontro el nombre de la carrera dentro del excel.
					carrera_cell = carrera_cell.strip
					# Se busca la carrera en la BD por su nombre e id de escuela.
					carrera_obj = Carrera.find_by(nombre_formateado: Carrera.new(nombre: carrera_cell).nombre_formateado, escuela_id: escuela_id, fecha_eliminacion: nil)

					if carrera_obj.nil?
						# No existe, se crea.
						carrera_obj = Carrera.new(nombre: carrera_cell, escuela_id: escuela_id, duracion_formal: carrera_duracion)
						detail[:carrera_inserted] = carrera_obj.nombre

						if !carrera_obj.save
							# Si hay problemas en crear la carrera en la BD.
							carrera_obj = nil
							response[:error] = true
							response[:msg] = "Ha ocurrido un problema en crear la carrera en el sistema. No se suben asignaturas."
						end
					end

					if !carrera_obj.nil?
						asignaturas_arr = []
						# RECORRER LAS ASIGNATURAS
						(1..spreadsheet.last_row).each do |row_num|
							# Para considerar la asignatura se cuenta:
							# 1.- La columna B debe tener un 1 (La fila que no tiene asignatura tiene NIL).
							# 2.- Las columnas de horas semanales presenciales (D,E,F) de la fila, al menos una de ellas debe ser distinto de 0.
							if spreadsheet.row(row_num)[1] == 1 && (spreadsheet.row(row_num)[3] != 0||spreadsheet.row(row_num)[4] != 0||spreadsheet.row(row_num)[5] != 0)
								asignatura_cell = spreadsheet.row(row_num)[2].sub(/\(.*\)/, '').strip

								if asignatura_cell !=~ /tutor(i|í)a/i
									# No contar las asignaturas con nombre 'tutoria'.
									# Buscar la asignatura en la BD por su nombre.
									asignatura_obj_aux = Asignatura.new(nombre: asignatura_cell)
									asignatura_obj = Asignatura.find_by(nombre_formateado: asignatura_obj_aux.nombre_formateado)

									if asignatura_obj.nil?
										asignatura_obj = asignatura_obj_aux
										# Se deja como NIL el objeto asignatura si no pasa las validaciones.
										if !asignatura_obj.valid?
											asignatura_obj = nil
										end
									end

									# Por ahora solo se van a guardar los objetos asignatura 
									if !asignatura_obj.nil?
										asignaturas_arr << asignatura_obj
									end

								end
							end
						end
						# FIN RECORRER LAS ASIGNATURAS

						if asignaturas_arr.size != 0
							# Guardar los ids de las asignaturas asociadas a la carrera para evitar generar asociaciones duplicadas.
							carrera_asig_ids = carrera_obj.asignatura_ids

							# Si se encontraron asignaturas.
							# Se pasa a insertar las asignaturas a la BD.
							asignaturas_arr.each do |a|
								if a.id.nil?
									# La asignatura no esta en la BD, se pasa a tratar de insertar.
									if a.save
										detail[:asignaturas_inserted] += 1
										carrera_obj.asignaturas << a unless carrera_asig_ids.include?(a.id)
									else
										detail[:asignaturas_failed] += 1
									end
								else
									# La asignatura ya esta en la BD, solo se asocia la carrera.
									detail[:asignaturas_found] += 1
									carrera_obj.asignaturas << a unless carrera_asig_ids.include?(a.id)
								end
							end
						else
							# No se encontraron asignaturas.
							response[:error] = true
							response[:msg] = "Se han encontrado 0 asignaturas dentro del excel."
						end

						if !response[:error]
							# Si no hay errores, se registra la carga masiva del usuario.
							self.tipo_carga = "carrera-asignatura"
							self.detalle = detail
							self.save
							response[:msg] = detail
						end
					end # carrera_obj.nil?
				else
					# No se encontro el nombre de la carrera en el excel.
					response[:error] = true
					response[:msg] = "Hubo un problema en encontrar el nombre de la carrera. Por favor revise el formato del excel."
				end
			else
				# No se encontro la duracion de la carrera.
				response[:error] = true
				response[:msg] = "Ha ocurrido un problema en encontrar la duración formal de la carrera."
			end # carrera_duracion != 0
		rescue RangeError => e
			# Error al no encontrar la hoja 'plan de estudios'
			response[:error] = true
			response[:msg] = "Ha ocurrido un problema en encontrar la hoja 'plan de estudios' del excel."
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

	def formatPeriodoAcademico(date_time_str)
		str_date = date_time_str[0...(date_time_str.size - 1)] # anio
		str_date += date_time_str.last.to_i == 1 ? "-01" : "-07"
		return DateTime.parse("#{str_date}-01")
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
