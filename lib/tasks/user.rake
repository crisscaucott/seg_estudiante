namespace :user do
	desc "Task para llenar la tabla de permisos de usuario, con sus tipos de permisos"
	task :fill_permission_table => :environment do
		permissions = ['Decano', 'Usuario normal']

		permissions.each do |p|
			up = UserPermission.new(name: p)
			up.save!
		end
	end

  desc "Crea un super usuario."
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
