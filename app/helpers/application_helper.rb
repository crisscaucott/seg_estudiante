module ApplicationHelper
	def header(text)
	  content_for(:header) { text.to_s }
	end

	def windowLocation(path)
		return "window.location.href='"+ path +"'"
	end

	def isActive(controller, action)
		class_name = ""
		begin
			class_name = "active" if current_page?(controller: controller, action: action)
			
		rescue StandardError => e
			
		end
		return class_name
	end
	
	def setActive(current_context, context_req)
		hash_options = {
			a_class: "list-group-item list-group-item",
			div_class: "list-group-submenu collapse",
			div_expanded: ""
		}
		if current_context == context_req
			hash_options[:a_class] += " active"
			hash_options[:div_class] += " in"
			hash_options[:div_expanded] += "aria-expanded='false'"
		end
		return hash_options
	end

	def setSubActive(controller)
		return current_page?(controller) ? " sub-active" : ""
	end

	def getFormattedAttrObjErrors(errors, class_name)
		str_errors = ""
		errors.each do |error_attr, error|
			str_errors += "<b>#{class_name.human_attribute_name(error_attr)}:</b> #{error.join(',')}<br>"
		end
		return str_errors.html_safe
	end

	def escandaloso1(str)
		puts "#{str}".colorize(:color => :white, :background => :green)
	end

	def isTutorOrDecanoHelper()
		if !(current_user.user_permission.name == "Decano" || current_user.user_permission.name == "Director")
			return false
		else
			return true
		end
	end

	def isUserType(user_type)
		if current_user.user_permission.name == user_type
			return true
		else
			return false
		end
	end
end
