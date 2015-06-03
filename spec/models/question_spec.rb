require 'rails_helper'

RSpec.describe Question, type: :model do
  
	before { @question = Question.new(title: "Test Question", body: "Pulvinar dapibus habitasse sociis sit pulvinar! Dignissim, scelerisque. Magna risus velit tincidunt, ultrices massa amet cursus nec, enim turpis scelerisque. Sagittis, scelerisque, pid, in eros?",user_id: User.first.id, category: Category.first) }

	it "should be valid with all fields" do 
		expect(@question.valid?).to eq(true)
	end

	it "should not be valid without title" do 
		@question.title = nil
		expect(@question.valid?).to eq(false)
	end

	it "should not be valid without title" do 
		@question.user_id = nil
		expect(@question.valid?).to eq(false)
	end

	it "should make urgent and answered false" do 
		@question.save
		expect(@question.urgent).to eq(false)
		expect(@question.answered).to eq(false)
	end

	it "should not be valid without body" do 
		@question.body = nil
		expect(@question.valid?).to eq(false)
	end

end
