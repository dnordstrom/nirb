module Nirb
  class Application
    def setup_environment(env)
      @nirb ||= {}
      @nirb[:request] = Rack::Request.new(env)
    end

    def call(env)
      setup_environment(env)
      render
      cleanup_environment
      output
    end

    def cleanup_environment
      @nirb.delete :template
      @nirb.delete :request
    end

    def output
      @nirb[:output]
    end

    def render
      template = File.expand_path(
        File.join(
          'templates',
          @nirb[:template] || '404.slim'
        )
      )
      
      result = Slim::Template.new(template).render(binding)
      @nirb[:output] = Rack::Response.new(reult).finish
    end
  end
end
