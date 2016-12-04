class AddDvToEstudiante < ActiveRecord::Migration
  def change
  	add_column :estudiante, :dv, :string, null: false
  end
end
