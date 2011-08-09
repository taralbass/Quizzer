ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'helpers/global_stub'
require 'helpers/active_record'
require 'helpers/enhanced_validate_uniqueness_of_matcher'
require 'helpers/factory_girl'

class ActiveSupport::TestCase
  include RR::Adapters::TestUnit

  def assert_true(value)
    assert_equal true, value
  end

  def assert_false(value)
    assert_equal false, value
  end
end
