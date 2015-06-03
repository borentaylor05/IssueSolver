require 'rails_helper'

RSpec.describe Reply, type: :model do
  
	before { @reply = Reply.new(question_id: Question.first.id, user_id: User.first.id, body: "Sit? Nec duis lacus cum. Aenean lacus! Rhoncus ultrices massa in pellentesque integer scelerisque nisi aliquet mattis magna tincidunt? Lacus?") }

	it "Should be valid" do 
		expect(@reply.valid?).to be(true)
	end

	it "should not be valid without user" do 
		@reply.user_id = nil
		expect(@reply.valid?).to be(false)
	end

	it "should not be valid without question" do 
		@reply.question_id = nil
		expect(@reply.valid?).to be(false)
	end

	it "should not be valid without body" do 
		@reply.body = nil
		expect(@reply.valid?).to be(false)
	end

end
