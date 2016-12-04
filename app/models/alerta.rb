class Alerta < ActiveRecord::Base
	self.table_name = "alerta"
	has_one :user, class_name: "User", foreign_key: "id", primary_key: "usuario_id"

end
