class MyDevises::SessionsController < Devise::SessionsController
	include ApplicationHelper
	private :sign_in_params

	def new
    super
  end

  def signIn
  	
  end

  def create
    user = User.find_for_database_authentication(email: params[:user][:email])
    
    return invalid_login_attempt unless user

    if user.valid_password?(params[:user][:password])
      # Usuario logueado con exito
      sign_in :user, user
      return render :js => windowLocation(root_path)
    else
      invalid_login_attempt
      
    end
  end

  protected
    def invalid_login_attempt
      set_flash_message(:alert, :invalid)
      render json: flash[:alert], status: 401
    end

  # def sign_in_params
  # 	params.require(:user).permit(:name, :last_name, :email, :password, :password_confirmation)
  # end

end
