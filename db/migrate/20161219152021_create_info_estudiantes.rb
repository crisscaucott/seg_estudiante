class CreateInfoEstudiantes < ActiveRecord::Migration
  def change
    create_table :info_estudiante do |t|
    	t.integer :estudiante_id, null: false
    	t.date :anio_matricula
    	t.date :fecha_matricula
    	t.string :sede
    	t.string :situacion
    	t.string :sexo
    	t.string :nacionalidad
    	t.date :fecha_nacimiento
    	t.string :direccion
    	t.string :comuna
        t.string :telefono_fijo
    	t.string :telefono_movil
    	t.string :correo_google_ucen
    	t.string :codigo_colegio
    	t.string :nombre_colegio
    	t.string :tipo_colegio
    	t.string :tipo_ensenanza
    	t.string :comuna_colegio
    	t.string :region_colegio
    	t.date :anio_egreso
    	t.string :tipo_ingreso
    	t.date :anio_psu_ingreso
    	t.decimal :nota_nem_ingreso, precision: 4, scale: 2
    	t.integer :psu_lenguaje
    	t.integer :psu_matematica
    	t.integer :psu_historia
    	t.integer :psu_ciencias
    	t.integer :puntaje_nem_ingreso
    	t.decimal :puntaje_pond_ingreso, precision: 6, scale: 2
    	t.string :tipo_programa
    	t.string :facultad
    	t.string :jornada
      t.timestamps null: false
    end

    add_foreign_key :info_estudiante, :estudiante, column: :estudiante_id
  end
end
