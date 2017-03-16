class CodigoPlanNullsToCarrera < ActiveRecord::Migration
  def up
  	change_column :carrera, :codigo, :string, null: true
  	change_column :carrera, :plan, :string, null: true
  end

  def down
  	change_column :carrera, :codigo, :string, null: false
  	change_column :carrera, :plan, :string, null: false
  end
end
