class Reply < ActiveRecord::Base

	validates :body, presence: true
	validates :user_id, presence: true
	validates :question_id, presence: true

	belongs_to :question
	belongs_to :user

	default_scope { order('created_at ASC') }

end
