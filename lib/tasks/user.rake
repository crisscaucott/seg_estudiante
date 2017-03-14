namespace :user do
	desc "Task para llenar la tabla de permisos de usuario, con sus tipos de permisos. Esto se debería hacer solo 1 vez, ya que hay que truncar todas las tablas que tengan relación con el usuario."
	task :fill_permission_table => :environment do
		permissions = ['Decano', 'Director', 'Tutor', 'Usuario normal']
    permissions_count = UserPermission.where(name: permissions).count

    if permissions_count != permissions.count
      ActiveRecord::Base.connection.execute("TRUNCATE #{UserPermission.table_name} CASCADE")

  		permissions.each do |p|
        up = UserPermission.new(name: p)
        up.save!
        puts "Permiso '#{p}' ingresado al sistema exitosamente."
  		end
    else
      puts "Los permisos de usuario ya se encuentran ingresados en el sistema."
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
