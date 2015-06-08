class AddHowToToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :how_to, :boolean, default: false
  end
end
