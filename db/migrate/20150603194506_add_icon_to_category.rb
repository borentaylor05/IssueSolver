class AddIconToCategory < ActiveRecord::Migration
  def change
  	add_column :categories, :icon, :string, default: nil
  end
end
