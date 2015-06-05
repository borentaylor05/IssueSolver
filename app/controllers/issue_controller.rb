class IssueController < ApplicationController

	before_action :authenticate_user!

	def home
	end

	# API-like controllers
	def get_issues
		if !params[:category] and !params[:status]
			respond({ status: 0, questions: Question.where(answered: false).limit(25) })
		else
			if params[:category]
				params[:category] = params[:category].split("-").join(" ")
			end
			cat = Category.find_by(name: params[:category])
			answered = false 
			both = false
			if params[:status] == 'answered'
				answered = true
			elsif params[:status] == 'both'
				both = true
			end	
			Rails.logger.info("CAT - #{cat} --- TYPE - #{params[:status]}")
			if cat and both
				respond({ status: 0, questions: Question.where(category: cat).limit(25) })
			elsif cat and !both
				respond({ status: 0, questions: Question.where(category: cat, answered: answered).limit(25) })
			elsif !cat and both 
				respond({ status: 0, questions: Question.all.limit(25) })
			elsif !cat and !both
				respond({ status: 0, questions: Question.where(answered: answered).limit(25) })
			else
				respond({ status: 1, error: "Check Query" })
			end
		end
	end

	def get_categories
		cats = [ { name: "recent", icon: 'star', id: 999 } ]
		Category.all.each { |cat| cats.push(cat) }
		respond({ status: 0, categories: cats })
	end
	
end
