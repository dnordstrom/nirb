module Nirb
  class Application
    def initialize
      @nirb = {
        template: 'index.slim'
      }
    end

    def call(env)
      initialize

      Rack::Response.new('Hello world').finish
    end

    def render_template
      template = @nirb[:template] || '404.slim'
      Slim::Template.new(template).render(bindings)
    end
  end
end
