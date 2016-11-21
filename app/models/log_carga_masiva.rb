class LogCargaMasiva < ActiveRecord::Base

	def self.readExcelFile(file)
		spreadsheet = open_spreadsheet(file)
		header = spreadsheet.row(1)
	  byebug
	  (2..spreadsheet.last_row).each do |i|
	    row = Hash[[header, spreadsheet.row(i)].transpose]
	  	byebug
	    # product = find_by_id(row["id"]) || new
	    # product.attributes = row.to_hash.slice(*accessible_attributes)
	    # product.save!
	  end
	end

	def self.open_spreadsheet(file)
	  case file.extname
		  when '.csv' then Roo::Csv.new(file.realpath, packed: false, file_warning: :ignore)
		  when '.xls' then Roo::Excel.new(file.realpath, packed: false, file_warning: :ignore)
		  when '.xlsx' then Roo::Excelx.new(file.realpath, packed: false, file_warning: :ignore)
		  else raise "Unknown file type: #{file.original_filename}"
	  end
	end

end
