namespace :user do
	desc "Task para llenar la tabla de permisos de usuario, con sus tipos de permisos"
	task :fill_permission_table => :environment do
		permissions = ['Decano', 'Usuario normal']

		permissions.each do |p|
			up = UserPermission.new(name: p)
			up.save!
		end
	end
end
