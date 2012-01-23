module Nirb
  class Application
    def initialize
      @nirb = {}
    end

    def call(env)
      initialize

      Rack::Response.new('Hello world').finish
    end
  end
end
