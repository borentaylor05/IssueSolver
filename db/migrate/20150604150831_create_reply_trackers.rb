class CreateReplyTrackers < ActiveRecord::Migration
  def change
    create_table :reply_trackers do |t|
      t.integer :user_id
      t.integer :question_id
      t.integer :unread

      t.timestamps null: false
    end
  end
end
