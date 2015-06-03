
class Jive

	include HTTParty
	

	def initialize(instance)
		@proxy = URI(ENV["QUOTAGUARDSTATIC_URL"]) if ENV["QUOTAGUARDSTATIC_URL"]
		@options = {}
		if @proxy
			@options = {http_proxyaddr: @proxy.host,http_proxyport: @proxy.port, http_proxyuser: @proxy.user, http_proxypass: @proxy.password}
		end
		case instance
		when 'dev'
			@url = "http://localhost:8080/api/core/v3"
			@auth = { username: 'admin', password: 'admin' }
		when 'social'
			@url = "https://social.teletech.com/api/core/v3"
			@auth = { username: ENV["SKE_USERNAME"], password: ENV["SKE_PASSWORD"] }
		when 'wwc'
			@url = "https://weightwatchers.jiveon.com/welcome"
			@auth = { username: ENV['WWC_USERNAME'], password: ENV['WWC_PASSWORD'] }
		end
		@options[:basic_auth] = @auth
		@options[:headers] = {'Content-Type' => 'application/json'}
	end

	def test_grab(url)
		return HTTParty.get("#{url}", @options).body
	end

	def grab(resource)
	    json = HTTParty.get("#{@url}#{resource}", @options).body
	    if json 
	      clean(json)
	    else
	      puts json
	    end
	end

	def update(resource, params)
		#  puts url
		@options[:body] = params.to_json
		@options = { body: params.to_json, basic_auth: @auth }
		return HTTParty.put("#{@url}#{@resource}", @options)
	end

	def create(resource, params)
        @options[:body] = params.to_json
        json = HTTParty.post("#{@url}#{resource}", @options).parsed_response
        return json
    end

	def remove(resource)
		json = HTTParty.delete("#{@url}#{resource}", @options)
	end

	def clean(json)
		if json 
        	return JSON.parse(json.gsub!(/throw [^;]*;/, ''))
        else
        	return false
        end
    end

	def people_search(name)
    	grab("#{@url}/search/people?filter=search(#{name.gsub(/\s+/, ",")})", @auth)
  	end

end