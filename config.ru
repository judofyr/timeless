Encoding.default_external = "utf-8"

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
end

public = Rack::File.new('public')

require_relative 'app/web'
app    = Web

run Rack::Cascade.new([public, app])
