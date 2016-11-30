module MassLoadHelper
	def uploadFile(file)
		uploaded_io = file
		res = {file_path: nil}
		begin
			excel_file = Rails.root.join('public', 'uploaded', uploaded_io.original_filename)
			File.open(excel_file, 'wb') do |file|
			  file.write(uploaded_io.read)
			end
			res[:file_path] = excel_file
		rescue StandardError => e
			byebug
			res[:file_path] = nil
		end
		return res
	end

	def formatDateToSemesterPeriod(date)
		semester = date.month < 7 ? "1" : "2"
		return "#{date.year} - #{semester}"
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
