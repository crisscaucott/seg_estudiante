namespace :user do
	desc "Task para llenar la tabla de permisos de usuario, con sus tipos de permisos. Esto se debería hacer solo 1 vez, ya que hay que truncar todas las tablas que tengan relación con el usuario."
	task :fill_permission_table => :environment do
    ActiveRecord::Base.connection.execute("TRUNCATE #{UserPermission.table_name}, #{User.table_name}, #{Reporte.table_name}, #{LogCargaMasiva.table_name}, #{Alerta.table_name} RESTART IDENTITY")
		permissions = ['Decano', 'Director', 'Tutor', 'Usuario normal']

		permissions.each do |p|
			up = UserPermission.new(name: p)
			up.save!
		end
	end

  desc "Crea un super usuario. Sirve para tener un usuario base inicial para crear a los demás usuarios del sistema."
  task :create_super_user => :environment do
    up = UserPermission.select(:id).where(name: "Decano").first

    user = User.new(name: "Super Usuario", last_name: "de prueba", email: 'criss.acv@gmail.com', encrypted_password: '123456', password: '123456', rut: '111111111', id_permission: up.id)

    if user.save
      puts "Usuario creado exitosamente con id: #{user.id}"
    else
      puts "Fallo en crear el usuario."
    end
  end
end
