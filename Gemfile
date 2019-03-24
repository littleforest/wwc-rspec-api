# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'puma', '~> 3.11'
gem 'rails', '~> 5.2.0'
gem 'sqlite3'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

gem 'bootsnap', '>= 1.1.0', require: false

gem 'active_model_serializers', '~> 0.10.0'

# For authorization
gem 'pundit'

# For http requests
gem 'http'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry'
  gem 'rspec-rails', '~> 3.8'
  gem 'rubocop'
end

group :development do
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'database_cleaner'
  gem 'webmock'
  gem 'vcr'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
