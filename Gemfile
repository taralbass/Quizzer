source 'http://rubygems.org'

gem 'rails', '3.0.9'

gem 'pg'
gem 'andand'
gem 'haml'
gem 'sass'
gem 'jquery-rails', '>= 1.0.3'
gem 'therubyracer'
gem 'json'
gem 'barista'


# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

group :development do
  gem 'factory_girl_rails'
end

group :test do
  #:require => false fixes some sort of load order issue with mocha (expectations weren't triggering)
#  gem 'mocha', :require => false
  gem 'thoughtbot-shoulda', :require => 'shoulda'
  gem 'factory_girl_rails'
  gem 'rr'
end
