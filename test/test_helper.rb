ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

Mocha::Configuration.prevent(:stubbing_non_existent_method)

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end


class ActiveRecord::Base
  def self.nonexistent_id
    last_object = unscoped.last :order => :id
    last_object ? last_object.id + 1 : 1
  end
  def self.latest
    unscoped.last :order => [ :created_at, :id ]
  end
end
