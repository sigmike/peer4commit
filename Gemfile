source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.0'

# Databases
gem 'sqlite3', group: :development
gem 'mysql2', group: :mysql
gem 'pg', '~> 0.20.0', group: :postgresql # fixed version to avoid warning, see https://stackoverflow.com/questions/44607324/installing-newest-version-of-rails-4-with-postgres-the-pgconn-pgresult-and-p

# Use SCSS for stylesheets
gem 'sass-rails'
gem 'haml-rails'

# use fork to remove warning, see https://github.com/metaskills/less-rails/issues/122 and https://github.com/metaskills/less-rails/pull/137
gem "less-rails", git: 'https://github.com/brendon/less-rails.git', branch: 'fix-sprockets-loading'

gem 'twitter-bootstrap-rails', git: 'https://github.com/seyhunak/twitter-bootstrap-rails.git', branch: 'bootstrap3'

gem 'kaminari'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'devise'
gem 'test_after_commit', :group => :test # https://github.com/plataformatec/devise/blob/master/CHANGELOG.md#410
gem 'omniauth'
gem 'omniauth-github', git: 'https://github.com/alexandrz/omniauth-github.git', branch: 'provide_emails'
gem 'cancancan'
gem 'twitter_bootstrap_form_for', git: 'https://github.com/stouset/twitter_bootstrap_form_for.git'

gem 'octokit'

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use debugger
# gem 'debugger', group: [:development, :test]

group :development do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-rvm', git: 'https://github.com/capistrano/rvm.git'
  gem 'capistrano-bundler', '>= 1.1.0'
  gem 'capistrano-rails'
  gem 'quiet_assets'
end

gem 'airbrake'
gem 'httparty'
gem 'whenever'
gem 'rqrcode-rails3'
gem 'exception_notification'
gem 'rack-canonical-host'
gem 'bootstrap_form', '~> 2.3.0' # version 2.4.0 raises a "can't modify frozen string" in gemspec evaluation on old systems
gem 'html_pipeline_rails'
gem 'rails_autolink'
gem 'redcarpet'
gem 'sanitize'
gem 'twitter-typeahead-rails'
gem 'commontator', '~> 4.6.0'
gem 'compass-rails'

group :test do
  gem 'cucumber-rails', :require => false
  # database_cleaner is not required, but highly recommended
  gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'poltergeist'
  gem 'timecop'
  gem 'capybara-screenshot'
end
gem 'awesome_print', group: [:development, :test]
gem 'commonmarker'
gem 'rack', '~> 1.6.11'
