class Question < ActiveRecord::Base

	validates :body, presence: true
	validates :title, presence: true
	validates :user_id, presence: true
	validates :category_id, presence: true

	belongs_to :user
	belongs_to :category
	has_many :replies

	default_scope { order('created_at DESC') }

end
