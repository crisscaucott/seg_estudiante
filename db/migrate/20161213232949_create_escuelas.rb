class CreateEscuelas < ActiveRecord::Migration
  def change
    create_table :escuela do |t|
    	t.string :nombre, null: false
    	t.string :codigo
    	# t.integer :director_id, null: false
      t.timestamps null: false
    end

    # add_foreign_key :escuela, :users, column: :director_id
  end
end
