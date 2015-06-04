require 'rails_helper'

RSpec.describe ReplyTracker, type: :model do
  before { @rt = ReplyTracker.new(user: User.first, question: Question.first, unread: 0) }

  it "should be valid" do 
  	expect(@rt.valid?).to eq(true)
  end

  it "should require user" do
  	@rt.user = nil
  	expect(@rt.valid?).to eq(false)
  end

  it "should require question" do
  	@rt.question = nil
  	expect(@rt.valid?).to eq(false)
  end

end
