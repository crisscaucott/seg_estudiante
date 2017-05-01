class EstadoDesercionHistorial < ActiveRecord::Base
	self.table_name = 'estado_desercion_historial'
	belongs_to :estudiante, class_name: "Estudiante"
	belongs_to :estado_desercion, class_name: "EstadoDesercion"
	belongs_to :usuario, class_name: "User"
end
