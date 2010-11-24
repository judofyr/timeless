require 'timeless'

if ENV['RACK_ENV'] != "production"
  require 'new_relic/rack/developer_mode'
  use NewRelic::Rack::DeveloperMode
end

public = Rack::File.new('public')
app    = Timeless

run Rack::Cascade.new([public, app])
