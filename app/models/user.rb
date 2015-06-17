class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

    validates :name, presence: true
  #  validates :jive_id, presence: true
    validates :employee_id, presence: true

    has_many :questions
    has_many :replies

    has_many :reply_trackers
    has_many :questions, through: :reply_trackers

    def questions(answered, page = 1)
      start = 0
      limit = 25
      start = (limit * page) - limit
      case answered
      when 'answered'
        return Question.joins(:reply_trackers).where(reply_trackers: { user_id: self.id }, questions: { answered: true }).offset(start).limit(limit)
      when 'unanswered'
        return Question.joins(:reply_trackers).where(reply_trackers: { user_id: self.id }, questions: { answered: false }).offset(start).limit(limit)
      when 'both'
        return Question.joins(:reply_trackers).where(reply_trackers: { user_id: self.id }).offset(start).limit(limit)
      end
    end


end
