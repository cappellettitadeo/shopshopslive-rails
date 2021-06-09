source 'https://rubygems.org'

ruby '2.5.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

#change logging
gem "audited", "~> 4.7"
#similarity comparison algorithm
gem 'rubyfish'
#respond_to has been extracted to the responders gem
gem 'responders'
#The Shopify API gem allows Ruby developers to programmatically access the admin section of Shopify stores.
gem 'shopify_api'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.6'
# Use postgres as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use Stripe to do payment
gem 'stripe'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  gem 'pry-rails'
  gem 'pry-nav'
  gem 'pry'
  gem 'rspec-rails', '~> 3.7'
  gem 'vcr'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'factory_bot_rails', '~> 4.0'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'faker'
  gem 'database_cleaner'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Assets
gem 'bootstrap', '~> 4.0.0'
gem 'jquery-rails'

# Utility
gem 'devise'
gem 'jwt'
gem 'carrierwave'
gem 'mini_magick'
gem 'cloudinary'
gem 'rails_12factor', group: :production
gem 'dotenv-rails'
gem 'httparty'
gem 'fast_jsonapi', git: 'https://github.com/jiasilu/fast_jsonapi.git'
gem 'nokogiri'
gem "nilify_blanks"
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'airbrake', '~> 7.3'
gem 'newrelic_rpm'
gem 'geocoder'
gem "paranoia", "~> 2.2"
gem 'simple_command'
gem 'hashids'
gem 'kaminari'
gem 'fuzzy_match'
gem 'sassc', '~> 2.4'
