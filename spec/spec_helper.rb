$LOAD_PATH << "#{__dir__}/../lib"

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }
end
