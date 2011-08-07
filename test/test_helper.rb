ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'helpers/factory_girl'
require 'helpers/enhanced_validate_uniqueness_of_matcher'

Mocha::Configuration.prevent(:stubbing_non_existent_method)

class ActiveSupport::TestCase
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
