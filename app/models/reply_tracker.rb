class ReplyTracker < ActiveRecord::Base

	validates :user_id, presence: true
	validates :question_id, presence: true

	belongs_to :question 
	belongs_to :user

	default_scope { order('created_at DESC') }

	def increment_all(question, user)
		ReplyTracker.where(question: question).each do |rt|
			if rt.user != user
				Rails.logger.info("BEFORE <--------- #{rt.user.total_unread} for #{rt.user.name}")
				rt.increment!(:unread)
				rt.user.increment!(:total_unread)
				Rails.logger.info("AFTER <--------- #{rt.user.total_unread} for #{rt.user.name} ")
			end
		end
	end

end
