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
end
