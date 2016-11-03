class MyDevises::RegistrationsController < Devise::RegistrationsController

	private :sign_up_params

	def new
    super
  end

  def create

    build_resource(sign_up_params)

    if resource.valid?

	    if resource.save
	      if resource.active_for_authentication?
	        set_flash_message :notice, :signed_up if is_navigational_format?
	        sign_up(resource_name, resource)
	        return render :json => {:success => true}
	      else
	        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
	        expire_session_data_after_sign_in!
	        return render :json => {:success => true}
	      end
	    else
	      clean_up_passwords resource
	      return render :json => {:success => false}
	    end

    else
    	# Usuario no valido, por sus campos.
    	byebug

    end


  end

  def sign_up_params
  	params.require(:user).permit(:name, :last_name, :email, :password, :password_confirmation)
  end

end
