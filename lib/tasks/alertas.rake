namespace :alertas do

	desc "Task description"
	task :fill_frec_alertas => :environment do
		frec_alertas = [
			{dias: 7, mensaje: "1 semana"},
			{dias: 14, mensaje: "2 semanas"},
			{dias: 21, mensaje: "3 semanas"},
			{dias: 30, mensaje: "1 mes"},
		]

		frec_alertas.each do |fa|
			FrecAlerta.new(fa).save
		end
	end
end
