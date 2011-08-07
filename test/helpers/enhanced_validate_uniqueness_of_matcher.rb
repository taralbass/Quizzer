module Shoulda
  module ActiveRecord
    module Matchers
      class ValidateUniquenessOfMatcher < ValidationMatcher # :nodoc:
        private
        def find_existing
          if @existing = @subject.class.find(:first)
            true
          elsif FactoryGirl.registered? @subject.class.name.underscore
            @existing = Factory(@subject.class.name.underscore)
            true
          else
            @failure_message = "Can't find first #{class_name}, nor a factory"
            false
          end
        end
      end
    end
  end
end
