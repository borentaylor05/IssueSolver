class QuestionsController < ApplicationController
  	
  	before_action :authenticate_user!
  	after_filter :set_csrf_cookie_for_ng
  	before_action :verify, only: [:create_question]

  	def show
  	end

	def home
	end

	# API-like controllers

	def answer
		q = Question.find_by(id: params[:id])
		reply = Reply.find_by(id: params[:reply][:id])
		Rails.logger.info "THIS REPLY -------> #{params[:reply]} "
		if q and reply
			q.update_attributes(answered: true)
			reply.update_attributes(is_answer: true)
			respond({ status: 0, question: q })
		else
			respond({ status: 1, error: "Question #{params[:id]} not found. Or reply #{params[:reply][:id]} not found." })
		end
	end

	def get_question_replies
		q = Question.find_by(id: params[:id])
		if q 
			rt = ReplyTracker.find_by(question: q, user: current_user)
			if rt
				current_user.update_attributes(total_unread: current_user.total_unread -= rt.unread)
				rt.update_attributes(unread: 0)
			else
				Rails.logger.info("No RT for #{current_user.name} and #{q.title} ")
			end
			respond({ status: 0, replies: apify(q.replies) })
		else
			respond({ status: 1, error: "Question #{params[:id]} not found." })
		end
	end

	def create_question_reply
		q = Question.find_by(id: params[:id])
		if q
			r = Reply.new(
					body: params[:reply],
					user: current_user,
					question: q
				)
			if r.valid?
				r.save
				rt = ReplyTracker.find_by(user: current_user, question: q)
				if !rt
					rt = ReplyTracker.new(
						user: current_user,
						question: q,
						unread: 0
					)
					if rt.valid?
						rt.save
						rt.increment_all(q, current_user)
						respond({ status: 0, reply: r, message: "Tracking Replies" })
					else
						respond({ status: 1, error: "ReplyTracker error: #{rt.errors.full_messages}" })
					end
				else
					# increment number of unread for all users except current
					rt.increment_all(q, current_user)
					respond({ status: 0, reply: r }) 
				end
			else
				respond({ status: 1, error: r.errors.full_messages }) 
			end
		else
			respond({ status: 1, error: "Question #{params[:id]} not found." })
		end
	end

	def create_question
		q = Question.new(
			title: params[:title],
			body: params[:body],
			category: Category.find(params[:category][:id]),
			user: current_user
		)
		if q.valid?
			q.save
			rt = ReplyTracker.new(
				user: current_user,
				question: q,
				unread: 0	
			)
			if rt.valid? 
				rt.save
				respond({ status: 0, question: q })
			else
				respond({ status: 1, error: "ReplyTracker error: #{rt.errors.full_messages}" })
			end
		else
			respond({ status: 1, error: q.errors.full_messages })
		end
		
	end

	def get_questions
		if params[:category] == "my-questions"
			respond({ status: 0, questions: apify(current_user.questions(params[:status])), current: current_user })
		elsif !params[:category] and !params[:status]
			respond({ status: 0, questions: Question.where(answered: false).limit(25), current: current_user })
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
				respond({ status: 0, questions: apify(Question.where(category: cat).limit(25)), current: current_user })
			elsif cat and !both
				respond({ status: 0, questions: apify(Question.where(category: cat, answered: answered).limit(25)), current: current_user })
			elsif !cat and both 
				respond({ status: 0, questions: apify(Question.all.limit(25)), current: current_user })
			elsif !cat and !both
				respond({ status: 0, questions: apify(Question.where(answered: answered).limit(25)), current: current_user })
			else
				respond({ status: 1, error: "Check Query" })
			end
		end
	end

	def get_current_question
		if params[:id]
			q = Question.find_by(id: params[:id])
			if q
				respond({ status: 0, question: apify(q) })
			else
				respond({ status: 1, error: "Question #{params[:id]} not found." })
			end
		else
			respond({ status: 1, error: "Question not found." })
		end
	end

end
