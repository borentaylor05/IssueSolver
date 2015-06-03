class ApplicationController < ActionController::Base
  include ActionView::Helpers::DateHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    "/"
  end

  def respond(response)
  	respond_to do |format|
  		format.any(:json, :html) { render json: response }
  	end
  end

  # array = array of objects
    def apify(array)
        Rails.logger.info(array.class.name)
        if array.class.name == "ActiveRecord::Relation" or array.class.name == "ActiveRecord::Associations::CollectionProxy"
            newArr = []
            array.each do |a|
                na = a.attributes
                if a.user
                    na["user"] = a.user
                end
                na["created_at"] = "#{time_ago_in_words(a.created_at)} ago"
                newArr.push(na)
            end
            return newArr
        elsif array.class.name == "Question"
            a = array.attributes
            a[:user] = array.user
            a[:replies] = apify(array.replies)
            a[:created_at] = "#{time_ago_in_words(array.created_at)} ago"
            return a
        end 
    end
    
  def set_csrf_cookie_for_ng
  	cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def verified_request?
    super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
  end

  def verify
  	unless verified_request?
  		respond({ status: 1, error: "Unverified" })
  	end
  end

end
