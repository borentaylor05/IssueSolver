require 'rails_helper'

RSpec.describe User, type: :model do

	before { @user = User.new(email: "test2@example.com", password: "password", jive_id: 2, employee_id: '3170083', name: "Taylor Boren") }

	it "should be valid? with all fields" do 
		@user.save
		expect(@user.valid?).to eq(true)
	end

	it "should fail without a Jive ID" do 
		@user.jive_id = nil
		expect(@user.valid?).to eq(false)
	end

	it "should fail without a Employee ID" do 
		@user.employee_id = nil
		expect(@user.valid?).to eq(false)
	end

	it "should fail without a name" do 
		@user.name = nil
		expect(@user.valid?).to eq(false)
	end

	it "should succeed as mentor" do 
		@user.mentor = true
		expect(@user.valid?).to eq(true), @user.errors.full_messages
	end

end
