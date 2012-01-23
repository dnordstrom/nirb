module Nirb
  class Application
    def load_environment(env)
      @nirb ||= {
        # Application config
      }

      @nirb[:request] = Rack::Request.new(env)
    end

    def call(env)
      load_environment(env)
      respond
    end

    def cleanup_environment
      @nirb.delete :template
      @nirb.delete :request
    end

    def respond
      @nirb[:output] = Rack::Response.new( render_template ).finish
      
      cleanup_environment
      
      @nirb[:output]
    end

    def render_template
      template = File.expand_path(
        File.join(
          'templates',
          @nirb[:template] || '404.slim'
        )
      )
      
      Slim::Template.new(template).render(binding)
    end
  end
end
