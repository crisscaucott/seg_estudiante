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
end
