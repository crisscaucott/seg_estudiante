class CreateMotivoDesercions < ActiveRecord::Migration
  def change
    create_table :motivo_desercion do |t|
    	t.string :nombre, null: false
      # t.timestamps null: false
    end
  end
end
