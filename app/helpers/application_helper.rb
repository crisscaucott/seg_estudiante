module ApplicationHelper
	def header(text)
	  content_for(:header) { text.to_s }
	end

	def windowLocation(path)
		return "window.location.href='"+ path +"'"
	end

	def isActive(page_name)
		return "active" if current_page?(page_name)
	end
end
