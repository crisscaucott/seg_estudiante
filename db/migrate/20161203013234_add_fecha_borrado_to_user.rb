class AddFechaBorradoToUser < ActiveRecord::Migration
  def change
  	add_column :users, :deleted_at, :datetime, null: true
  end
end
