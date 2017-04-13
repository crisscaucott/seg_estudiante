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
			res[:file_path] = nil
		end
		return res
	end

	def formatDateToSemesterPeriod(date)
		semester = date.month < 7 ? "1" : "2"
		return "#{date.year} - #{semester}"
	end
end
