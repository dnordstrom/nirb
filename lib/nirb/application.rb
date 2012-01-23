module Nirb
  class Application
    # Constructor running on server start.
    def initialize
      @nirb = {}
    end

    # Application entry point, called by Rack on each request.
    # Responsible for setting up and cleaning up environment, and
    # processing current request.
    def call(env)
      setup_environment(env)
      process_request
      respond
    end

    private
    
    # Processes the current request. Walks the routes and calls
    # the appropriate code for rendering.
    def process_request
      walk_the_routes
    end

    # Sets environment variables for current request.
    def setup_environment(env)
      @nirb[:request] = Rack::Request.new(env)
      @nirb[:output] = nil
    end

    # Returns output, i.e. current response.
    def respond
      Rack::Response.new(@nirb[:output] || 'No template loaded.').finish
    end

    # Returns current request object.
    def request
      @nirb[:request]
    end

    # Returns params hash from `Rack::Request` object.
    def params
      @nirb[:request].params
    end

    # Returns all routes specified for application.
    def routes
      self.class.routes
    end

    # Iterates through routes and calls match.
    def walk_the_routes
      routes.each do |route|
        if route[:route] === request.path_info
          instance_eval &route[:block] unless route[:block].nil?
          @nirb = route[:class].new(@nirb).call unless route[:class].nil?
        end
        
        route_frags = route[:route].split('/')
        path_frags = request.path_info.split('/')
        
        if route_frags.length === path_frags.length
          route_frags.each_with_index do |frag, index|
            if frag[0,1] === ':'
              request.params[frag[1..-1].to_sym] = path_frags[index]
            elsif frag[0,1] === '@'
              request.params[:method] = path_frags[index]
            elsif path_frags[index] != frag
              break
            end

            if index === route_frags.length - 1
              instance_eval &route[:block] unless route[:block].nil?
              @nirb = route[:class].new(@nirb).call unless route[:class].nil?
            end
          end
        end
      end
    end

    # Processes Slim template and assigns result to output
    # variable for Rack response.
    def render(template)
      template = File.expand_path(File.join('templates', "#{template}.slim"))
      extension = File.extname(template)[1..-1]
      
      @nirb[:output] =
        send("render_#{extension}", template) if
          respond_to? "render_#{extension}", true
    end

    # Processes template and returns result, for use in
    # templates.
    def partial(template)
      template = File.expand_path(File.join('templates', "#{template}.slim"))
      extension = File.extname(template)[1..-1]
      
      send "render_#{extension}", template if
        respond_to? "render_#{extension}", true
    end

    # Slim template rendering.
    def render_slim(template)
      Slim::Template.new(template).render(self)
    end

    class << self
      attr_accessor :routes

      # Store route.
      def route(route, &block)
        @routes ||= []
        new_route = {}

        case route
        when String
          new_route[:route] = route
          new_route[:block] = block if block_given?
        when Hash
          new_route[:route] = route.first[0]
          new_route[:class] = route.first[1]
        end

        @routes << new_route
      end
    end
  end
end
