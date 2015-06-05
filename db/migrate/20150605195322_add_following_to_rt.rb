class AddFollowingToRt < ActiveRecord::Migration
  def change
  	add_column :reply_trackers, :following, :boolean, default: false
  end
end
