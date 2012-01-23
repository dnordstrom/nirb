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
      # Your call code here...

      call_with_pages
    end

    module ClassMethods
      
    end
  end
end
