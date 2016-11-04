class MyDevises::SessionsController < Devise::SessionsController
	include ApplicationHelper
	private :sign_in_params

	def new
    super
  end

  def signIn
  	
  end

  def create
    super
    # byebug
    # user = User.find_for_database_authentication(email: params[:user][:email])
  end

  # def sign_in_params
  # 	params.require(:user).permit(:name, :last_name, :email, :password, :password_confirmation)
  # end

end
