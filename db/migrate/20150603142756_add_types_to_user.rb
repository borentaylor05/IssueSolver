class AddTypesToUser < ActiveRecord::Migration
  def change
  	add_column :users, :admin, :boolean
  	add_column :users, :l2, :boolean
  end
end
