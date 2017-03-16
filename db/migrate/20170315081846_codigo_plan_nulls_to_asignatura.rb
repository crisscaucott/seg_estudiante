class CodigoPlanNullsToAsignatura < ActiveRecord::Migration
  def up
  	change_column :asignatura, :codigo, :string, null: true
  	change_column :asignatura, :creditos, :integer, null: true
  end

  def down
  	change_column :asignatura, :codigo, :string, null: false
  	change_column :asignatura, :creditos, :integer, null: false
  end
end
