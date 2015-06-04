

task nuke_questions: :environment do 
	Question.destroy_all
	Reply.destroy_all
	ReplyTracker.destroy_all
	User.all.each { |u| u.update_attributes(total_unread: 0) }
end