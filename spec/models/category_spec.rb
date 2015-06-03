require 'rails_helper'

RSpec.describe Category, type: :model do
  
	before { @category = Category.new(name: "Weight Loss") }

	it "Should be valid with name" do 
		expect(@category.valid?).to be(true)
	end

	it "Should be invalid without name" do 
		@category.name = nil
		expect(@category.valid?).to be(false)
	end

end
