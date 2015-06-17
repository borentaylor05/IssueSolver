class CategoriesController < ApplicationController

	before_action :verify, only: [:create_category]

	def get_categories
		if params[:dbonly]
			cats = []
		else
			cats = [ { name: "my questions", icon: 'fa-user', id: 998 }, { name: "recent", icon: 'fa-star', id: 999 } ]
		end
		Category.all.each { |cat| cats.push(cat) }
		respond({ status: 0, categories: cats })
	end

	def create_category
		params[:name] = params[:name].split("-").join(" ")
		c = Category.find_by(name: params[:name])
		params[:icon] ||= "question-circle"
		if c 
			respond({ status: 1, error: "Name - #{params[:name]} - is already taken." })
		else
			c = Category.new(
				name: params[:name].gsub!("/", "-"),
				icon: "fa-#{params[:icon]}"
			)
			if c.valid? 
				c.save
				respond({ status: 0, category: c })
			else
				respond({ status: 1, error: c.errors.full_messages })
			end
		end
	end

end
