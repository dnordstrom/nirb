module Nirb
  module Pages
    def included(base)
      base.class_eval do
        extend Nirb::Pages::ClassMethods
        
        alias_method :call_without_pages, :call
        alias_method :call, :call_with_pages
      end
    end

    def call_with_pages(env)
      initialize

      path = @nirb[:request].path_info
      file = File.expand_path "pages/#{path}.slim"

      if File.exists? file
        @nirb[:template] = file
      end

      call_without_pages
    end

    module ClassMethods
      
    end
  end
end
