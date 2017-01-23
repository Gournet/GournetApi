source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'devise_token_auth', :git => 'git://github.com/lynndylanhurley/devise_token_auth.git'

#Authentication
gem 'omniauth'
gem 'devise'
#cross-origin
gem 'rack-cors', :require => 'rack/cors'


#for stylezed emails
gem 'premailer-rails'
gem 'nokogiri'

#pagination
gem 'will_paginate', '~> 3.1.0'

#images
gem 'carrierwave', '~> 1.0'
gem "fog"
gem 'mini_magick'

#pretty print
gem "awesome_print", require:"ap"

#request limit
gem 'rack-attack'

#serializers
gem 'active_model_serializers', '0.10.0.rc4'
