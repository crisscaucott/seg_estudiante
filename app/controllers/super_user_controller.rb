class SuperUserController < ApplicationController
	before_action :isDecano


	def index
		
	end

	def isDecano
		if current_user.user_permission.name != "Decano"
			redirect_to :root, :status => 301, :flash => { msg: 'Usted no tiene los permisos para estar en esta sección.', alert_type: 'warning'}
		end		
	end
end
