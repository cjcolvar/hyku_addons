# frozen_string_literal: true
# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
require File.expand_path('internal_test_hyku/spec/rails_helper.rb', __dir__)

ENV['RAILS_ENV'] ||= 'test'
# require File.expand_path('../config/environment', __dir__)
require File.expand_path('internal_test_hyku/config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'factory_bot_rails'
FactoryBot.definition_file_paths = [File.expand_path("spec/factories", HykuAddons::Engine.root)]
FactoryBot.find_definitions

# For testing generators
require 'ammeter/init'
require 'capybara/apparition'

if ENV['CI']
  Capybara.register_driver :apparition do |app|
    Capybara::Apparition::Driver.new(app, js_errors: false)
  end
  Capybara.default_driver = :rack_test # This is a faster driver
  Capybara.javascript_driver = :apparition
  Capybara.default_max_wait_time = 10 # We may have a slow application, let's give it some time.

  # FIXME: Pin to older version of chromedriver to avoid issue with clicking non-visible elements
  # Webdrivers::Chromedriver.required_version = '72.0.3626.69'
end

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # They enable url_helpers not to throw error in Rspec system spec and request spec.
  # config.include Rails.application.routes.url_helpers
  config.include HykuAddons::Engine.routes.url_helpers
end
