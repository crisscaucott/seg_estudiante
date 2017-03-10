class CreateDestinos < ActiveRecord::Migration
  def change
    create_table :destinos do |t|
    	t.string :nombre, null: false
      # t.timestamps null: false
    end
  end
end
