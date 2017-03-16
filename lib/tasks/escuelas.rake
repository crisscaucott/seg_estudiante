namespace :escuelas do

	desc "Llenar la tabla de escuelas, con las escuelas de la facultad."
  task :fill_escuelas => :environment do
    escuelas = ['Escuela de Obras Civiles y Construcción', 'Escuela de Minería y Recursos Naturales', 'Escuela de Industrias', 'Escuela de Computación e Informática']
    escuelas_count = Escuela.where(nombre: escuelas).count

    if escuelas_count != escuelas.count
      ActiveRecord::Base.connection.execute("TRUNCATE #{Escuela.table_name} CASCADE")
      
	    escuelas.each do |e|
	      up = Escuela.new(nombre: e)
	      up.save!
	      puts "Escuela '#{e}' ingresado al sistema exitosamente."
			end

		else
			puts "Las escuelas ya se encuentran ingresadas en el sistema. En total hay #{escuelas.count} escuelas."
    	
    end
  end
end
