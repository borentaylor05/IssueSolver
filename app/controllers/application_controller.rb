class ApplicationController < ActionController::Base
  include ActionView::Helpers::DateHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  $valid_classes = [ "Array", "ActiveRecord::Relation", "ActiveRecord::Associations::CollectionProxy" ]
  $allowed_domains = [ 'localhost', 'weightwatchers.jiveon.com', 'social.teletech.com' ]
  def after_sign_in_path_for(resource)
    "/"
  end

  def cors_set_access_control_headers
    Rails.logger.info verify_domain
    headers['Access-Control-Allow-Origin'] = verify_domain
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  def maybe_login_from_token
    Rails.logger.info "maybe_login_from_token: '#{ params[:token] }'"
    return if (token = params[:token]).blank?

    if (user = User.find_by_token(token))
      Rails.logger.info "One time login token used for user #{ user.id }"
      sign_in(user)
    else
      Rails.logger.info "No user found from token: '#{ token }'"
    end

    # strip token regardless of success
  #  redirect_to request.path, params.except(:token, :action, :controller)
  end

  def respond(response)
  	respond_to do |format|
  		format.any(:json, :html) { render json: response }
  	end
  end

  def verify_domain
    if $allowed_domains.include? request.host
      Rails.logger.info(request.host)
      return request.headers['origin']
    else
      raise "Unauthorized - Invalid Origin - IP: #{request.remote_ip} - Domain - #{request.headers['origin']} - Referrer - #{request.referrer}"
    end
  end

  # array = array of objects
    def apify(array)
        Rails.logger.info(array.class.name)
        if $valid_classes.include?(array.class.name)
            newArr = []
            array.each do |a|
                na = a.attributes
                if a.user
                    na["user"] = a.user
                end
                na["created_at"] = "#{time_ago_in_words(a.created_at)} ago"
                if a.class.name == "Question"
                  ur = a.get_user_unread(current_user)
                  na[:unread] = ur[:unread]
                  na[:unread_status] = ur[:status]
                  na[:total_replies] = a.replies.size
                end
                newArr.push(na)
            end
            return newArr
        elsif array.class.name == "Question"
            a = array.attributes
            a[:user] = array.user
            a[:total_replies] = array.replies.size
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
