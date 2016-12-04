class CreateFrecAlerta < ActiveRecord::Migration
  def change
    create_table :frec_alerta do |t|
    	t.integer :dias, null: false
    	t.string :mensaje, null: false
    end
  end
end
