class MyDevise::RegistrationsController < Devise::RegistrationsController

	def new
    super
  end

  def create
  	byebug
    res = Usuario.createUser(params[:usuario])
  end

end
