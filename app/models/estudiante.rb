class Estudiante < ActiveRecord::Base
	belongs_to :carrera, class_name: "Carrera"
	belongs_to :estado_desercion, class_name: "EstadoDesercion"
	has_many :calificacions, class_name: "Calificacion", foreign_key: "estudiante_id"
  has_and_belongs_to_many :users, class_name: "User", foreign_key: "estudiante_id", join_table: "tutor_estudiante", association_foreign_key: 'usuario_id'

	validates_presence_of :nombre, :apellido, :rut, :dv, :fecha_ingreso, :carrera_id, :estado_desercion_id
	validate :validarRut
	self.table_name = 'estudiante'

	def self.getIdEstudianteByCarreraAndRut(rut, carrera_id, fields = [:id])
		return self.select(fields).where(rut: rut.to_s.strip).where(carrera_id: carrera_id).first
	end

	def self.getEstudianteFullNameById(id)
		estudiante_obj = self.select([:nombre, :apellido]).where(id: id).first
		full_name = estudiante_obj.nombre + " " + estudiante_obj.apellido
		return full_name
	end

	def self.getEstudiantesByUserType(user)
		estudiantes = []
		case user.user_permission.name
			when "Decano"
				# Todos los estudiantes
				estudiantes = getEstudiantes()
			when "Director"
				# Todos los estudiantes segun la carrera que tiene asignado el director.
				if !user.carrera_id.nil?
					estudiantes = getEstudiantes({carrera: user.carrera_id})
				else
					# Cuando es el usuario es director pero no tiene asignado su carrera,
					# se debe mostrar error.
					estudiantes = false
				end

			when "Tutor"
				# Todos los estudiantes que tiene asociado su tutor.
				estudiantes = user.estudiantes

			else
				# Todos los estudiantes (Usuario Normal)
				estudiantes = getEstudiantes()
		end

		return estudiantes
	end

	def self.getEstudiantes(filters = {})
		estudiantes = self.all.order(nombre: :asc)

		if filters[:anio_ingreso].present?
			since_date = "#{filters[:anio_ingreso]}-01-01"
			until_date = "#{filters[:anio_ingreso].to_i + 1}-01-01"
			estudiantes = estudiantes.where("(fecha_ingreso >= ? AND fecha_ingreso < ?)", since_date, until_date)
		end

		if filters[:carrera].present?
			estudiantes = estudiantes.where(carrera_id: filters[:carrera])
		end

		if filters[:estado_desercion].present?
			estudiantes = estudiantes.where(estado_desercion_id: filters[:estado_desercion])
		end

		return estudiantes
	end

	def validarRut
		rut = self.rut + self.dv
		self.errors[:rut] << "Rut inválido." if !RUT::validar(rut)
	end

	def nombre=(new_nombre)
		self[:nombre] = new_nombre.strip.titleize
	end

	def apellido=(new_apellido)
		self[:apellido] = new_apellido.strip.titleize
	end

	def rut=(new_rut)
		self[:rut] = new_rut.strip
	end

	def dv=(new_dv)
		self[:dv] = new_dv.strip
	end
end
