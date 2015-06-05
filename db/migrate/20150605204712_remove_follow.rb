class RemoveFollow < ActiveRecord::Migration
  def change
  	remove_column :reply_trackers, :following
  end
end
