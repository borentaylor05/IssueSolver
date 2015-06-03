class Category < ActiveRecord::Base

	before_save { |cat| cat.name.downcase! }
	
	validates :name, presence: true

end
