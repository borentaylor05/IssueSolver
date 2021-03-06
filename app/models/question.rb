class Question < ActiveRecord::Base

	validates :body, presence: true
	validates :title, presence: true
	validates :user_id, presence: true
	validates :category_id, presence: true

	belongs_to :user
	belongs_to :category
	has_many :replies
	has_many :reply_trackers
	has_many :users, through: :reply_trackers 	

	default_scope { order('created_at DESC') }

	def get_user_unread(user)
		rt =  ReplyTracker.find_by(question: self, user: user)
		if rt 
			return { unread: rt.unread, status: true } 
		else
			return { unread: 0, status: false }
		end		
	end

	def answer
		self.replies.each do |r|
			return r if r.is_answer
		end
	end

end
