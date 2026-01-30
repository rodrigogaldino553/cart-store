source "https://rubygems.org"

ruby "3.3.1"
gem "rails", "~> 7.1.3", ">= 7.1.3.2"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[windows jruby]
gem "bootsnap", require: false

gem "redis", "~> 5.2"
gem "sidekiq", "~> 7.2", ">= 7.2.4"
gem "sidekiq-scheduler", "~> 5.0", ">= 5.0.3"

gem "guard", "~> 2.19"
gem "guard-livereload", require: false

group :development, :test do
  gem "bullet", "~> 7.0"
  gem "debug", platforms: %i[mri windows]
  gem "factory_bot_rails", "~> 6.2"
  gem "faker"
  gem "rspec-rails", "~> 6.1.0"
  gem "simplecov", require: false
  gem "standard"
  gem "standard-rails"
end

group :development do
end
