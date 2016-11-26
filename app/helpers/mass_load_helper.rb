module MassLoadHelper
	def uploadFile(file)
		uploaded_io = file
		res = {file_path: nil}
		begin
			excel_file = Rails.root.join('public', 'uploaded', uploaded_io.original_filename)
			File.open(excel_file, 'wb') do |file|
			  file.write(uploaded_io.read)
			end
			res[:file_path] = uploaded_io.original_filename
		rescue StandardError => e
			res[:file_path] = nil
		end
		return res
	end
end
