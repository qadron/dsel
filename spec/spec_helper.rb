require 'bundler/setup'
require 'dsel'

require_relative 'support/helpers/paths'

Dir.glob( "#{support_path}/{fixtures}/**/*.rb" ).each { |f| require f }

RSpec.configure do |config|
    # Enable flags like --only-failures and --next-failure
    config.example_status_persistence_file_path = '.rspec_status'

    # Disable RSpec exposing methods globally on `Module` and `main`
    config.disable_monkey_patching!

    config.expect_with :rspec do |c|
        c.syntax = :expect
    end

    config.before :each do
        DSeL::API::Generator.reset
    end
end
