class InfoEstudiante < ActiveRecord::Base
	self.table_name = 'info_estudiante'

	belongs_to :estudiante, class_name: "Estudiante", foreign_key: :estudiante_id

	def anio_matricula=(new_anio_matricula)
		self[:anio_matricula] = Date.parse("#{new_anio_matricula.to_i}-01-01")
	end

	def anio_egreso=(new_anio_egreso)
		self[:anio_egreso] = Date.parse("#{new_anio_egreso.to_i}-01-01")
	end

	def anio_psu_ingreso=(new_anio_psu_ingreso)
		self[:anio_psu_ingreso] = Date.parse("#{new_anio_psu_ingreso.to_i}-01-01")
	end

	def sexo=(new_sexo)
		self[:sexo] = new_sexo.to_s.strip.downcase
	end

	def nacionalidad=(new_nacionalidad)
		self[:nacionalidad] = new_nacionalidad.to_s.strip.capitalize
	end

	def comuna=(new_comuna)
		self[:comuna] = new_comuna.to_s.strip.titleize
	end

	def codigo_colegio=(new_codigo_colegio)
		self[:codigo_colegio] = new_codigo_colegio.to_i.to_s
	end

	def tipo_colegio=(new_tipo_colegio)
		self[:tipo_colegio] = new_tipo_colegio.to_s.strip.capitalize
	end

	def tipo_ensenanza=(new_tipo_ensenanza)
		self[:tipo_ensenanza] = new_tipo_ensenanza.to_s.strip.titleize
	end

	def comuna_colegio=(new_comuna_colegio)
		self[:comuna_colegio] = new_comuna_colegio.to_s.strip.titleize
	end

	def region_colegio=(new_region_colegio)
		self[:region_colegio] = new_region_colegio.to_s.strip.titleize
	end

	def tipo_programa=(new_tipo_programa)
		self[:tipo_programa] = new_tipo_programa.to_s.strip.capitalize
	end

	def facultad=(new_facultad)
		self[:facultad] = new_facultad.to_s.strip.capitalize
	end

	def situacion=(new_situacion)
		self[:situacion] = new_situacion.to_s.strip.titleize
	end

	def jornada=(new_jornada)
		self[:jornada] = new_jornada.to_s.strip.capitalize
	end

	def sede=(new_sede)
		self[:sede] = new_sede.to_s.strip.capitalize
	end
end
