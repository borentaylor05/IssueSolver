class FixCategories < ActiveRecord::Migration
  def change
  	remove_column :questions, :category
  	add_column :questions, :category_id, :integer
  end
end
