class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

    validates :name, presence: true
    validates :jive_id, presence: true
    validates :employee_id, presence: true

    def questions(answered)
    	case answered
    	when 'answered'
    		return Question.where(user: self, answered: true)
    	when 'unanswered'
    		return Question.where(user: self, answered: false)
    	when 'both'
    		return Question.where(user: self)
    	end
    end

    has_many :questions
    has_many :replies

end
