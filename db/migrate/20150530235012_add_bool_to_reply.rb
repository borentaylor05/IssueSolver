class AddBoolToReply < ActiveRecord::Migration
  def change
  	add_column :replies, :is_answer, :boolean, default: false
  end
end
