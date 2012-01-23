module Nirb
  module Pages
    def self.included(base)
      base.class_eval do
        extend Nirb::Pages::ClassMethods
        
        alias_method :call_without_pages, :call
        alias_method :call, :call_with_pages
      end
    end

    def call_with_pages(env)
      load_environment(env)

      template = @nirb[:request].path_info[1..-1] + '.slim'
      path = File.expand_path "templates/#{template}"
      
      if File.exists? path
        print "\n\nsetting template to #{template}\n\n"
        @nirb[:template] = template
      end

      call_without_pages(env)
    end

    module ClassMethods
      
    end
  end
end
