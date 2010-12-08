task :app do
  require 'rack'
  Rack::Builder.parse_file('config.ru')
  include Timeless::Models
end

namespace :change do
  desc 'Create a change for an entry'
  task :post, [:entry] => :app do |n, args|
    require 'yaml'
    n = Change.last.id + 1
    File.open("changes/#{n}.yaml", "w") do |f|
      f << {
        "created_at" => Time.now,
        "entry" => args[:entry]
      }.to_yaml
    end
  end
end
