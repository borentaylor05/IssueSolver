class AddFieldsToUser < ActiveRecord::Migration
	def change
		add_column :users, :name, :string
		add_column :users, :employee_id, :string
		add_column :users, :jive_id, :integer
		add_column :users, :mentor, :boolean, default: false
	end
end
