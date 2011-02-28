require 'timeless'

class RedirectToProperDomain
  def initialize(app, domain)
    @app = app
    @domain = domain
    @cache = {}
  end
  
  def call(env)
    if @domain == env['HTTP_HOST']
      @app.call(env)
    else
      [301, {
        'Location' => "http://#{@domain}#{env['PATH_INFO']}",
        'Content-Type' => "text/html"
      }, []]
    end
  end
end

if ENV['RACK_ENV'] == "production"
  use RedirectToProperDomain, 'timelessrepo.com'
else
  require 'new_relic/rack/developer_mode'
  use NewRelic::Rack::DeveloperMode
end

public = Rack::File.new('public')
app    = Timeless

run Rack::Cascade.new([public, app])
