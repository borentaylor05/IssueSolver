class AddBooleansToQuestions < ActiveRecord::Migration
  def change
  	add_column :questions, :urgent, :boolean, default: false
  	add_column :questions, :answered, :boolean, default: false
  end
end
