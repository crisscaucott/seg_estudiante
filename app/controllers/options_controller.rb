class OptionsController < ApplicationController
	include ApplicationHelper
	CONTEXTS = {
		pass: 'pass'
	}
	def index
		render action: :index, locals: {context: nil}
	end

	def change_pass_index
		render action: :index, locals: {partial: 'change_pass', context: CONTEXTS[:pass]}
	end

	def change_pass
		usr_data = new_pass_filter_params

		# Actualizar contraseña del usuario.
		current_user.assign_attributes(usr_data)

		if current_user.valid?
			# Contrasena correcta

			current_user.save

			render json: {msg: "Contraseña actualizada exitosamente.", type: :success}
		else
			# Algo fallo con la contrasena
			render json: {msg: getFormattedAttrObjErrors(current_user.errors.messages, User), type: :danger}, status: :bad_request
		end
	end

	private
		def new_pass_filter_params
			params.require(:user).permit([:password, :password_confirmation])
		end
end
