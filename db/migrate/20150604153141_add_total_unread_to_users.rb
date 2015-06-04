class AddTotalUnreadToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :total_unread, :integer, default: 0
  end
end
