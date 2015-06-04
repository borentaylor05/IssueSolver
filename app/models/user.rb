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

    def questions(answered)
      questions = []
      case answered
      when 'answered'
        self.reply_trackers.limit(25).each { |rt| questions.push(rt.question) if rt.question.answered }
      when 'unanswered'
        self.reply_trackers.limit(25).each { |rt| questions.push(rt.question) if !rt.question.answered }
      when 'both'
        self.reply_trackers.limit(25).each { |rt| questions.push(rt.question) }
      end
      return questions
    end


end
