class EstudiantesAlerta < ActiveRecord::Base
	belongs_to :alerta, class_name: "Alerta"


	def self.timesEstudiantesInAlerta(est_id)
		return self.select("date_trunc('day', created_at) AS alerta").where(estudiante_id: est_id).group("alerta")
	end

end
