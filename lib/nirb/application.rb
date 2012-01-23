module Nirb
  class Application
    # Application entry point, called by Rack on each request.
    # Responsible for setting up and cleaning up environment, and
    # processing current request.
    def call(env)
      setup_environment(env)
      process_request
      cleanup_environment
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
      @nirb ||= {}
      @nirb[:request] = Rack::Request.new(env)
    end

    # Cleans up environment variables to get ready for the next
    # request.
    def cleanup_environment
      @nirb.delete :template
      @nirb.delete :request
    end

    # Returns output, i.e. current response.
    def respond
      @nirb[:output] ||= render '404.slim'

      Rack::Response.new @nirb[:output]
    end

    # Processes Slim template and returns result.
    def render(template)
      template = File.expand_path( File.join('templates', template) )
      @nirb[:output] = Slim::Template.new(template).render(binding)
    end

    # Returns all routes specified for application.
    def routes
      self.class.routes
    end

    # Iterates through routes and calls match.
    def walk_the_routes
      routes.each do |route|
        print "\n\n#{route.inspect}\n\n"
        if route === request.path_info
          route[:block].call unless route[:block].nil?
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
              route[:block].call unless route[:block].nil?
              @nirb = route[:class].new(@nirb).call unless route[:class].nil?
            end
          end
        end
      end
    end

    # Returns current request object.
    def request
      @nirb[:request]
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
