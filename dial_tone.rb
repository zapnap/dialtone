require "rack" 
require "erubis"

class DialTone
  attr_reader :request, :response

  def initialize
    @routes = {}
    puts "Waiting for calls..."
  end

  # center of all things Rack...
  def call(env)
    @request = Rack::Request.new(env)
    @response = Rack::Response.new

    answer(@request.path_info)
    @response.finish
  end

  # answer incoming requests, look up the route, hand off to the right method
  def answer(path)
    puts "- Requested URL: #{path}"
    puts "- Answering the call: #{self.class.routes[path] || '(404)'}"

    method = self.class.routes[path]
    if method.nil?
      @response.status = 404
    else
      send(self.class.routes[path])
    end
  end

  # erb content helper
  def erb(content)
    @response.write(Erubis::Eruby.new(content).result)
  end

  # these methods are directly available in DialTone clients (inherit from DialTone)
  class << self
    attr_accessor :routes

    def inherited(subclass)
      # make routes available
      subclass.routes = @routes || {}
    end

    # define a routing endpoint and content for that route
    #
    # answer "/my/url" do
    #   erb "The time is now <%= Time.now %>"
    # end
    #
    def answer(route, &block)
      method_name = "__answer#{clean_path(route)}"
      routes[route] = method_name
      define_method(method_name, &block)
    end

    # clean path for dynamic method naming
    def clean_path(path)
      path.gsub(/\/|\./, '__')
    end
  end
end
