require 'bundler'
Bundler.setup

require 'yaml'
require 'time'

require 'camping'
require 'tilt'
require 'haml'
require 'maruku'
require_relative 'maruku-rouge'

Camping.goes :Timeless

require_relative 'timeless/models/entry'
require_relative 'timeless/models/change'

class NotFound < StandardError; end

module Timeless
  set :views, File.dirname(__FILE__) + '/timeless/views'
  set :dynamic_templates, true
  set :last_modified, Time.now
  
  set :haml, {
    :format => :html5,
    :escape_html => true,
    :ugly => true
  }
  
  Authors = {
    'judofyr' => {
      :name => 'Magnus Holm',
      :site => 'http://judofyr.net/'
    },
    
    'steveklabnik' => {
      :name => 'Steve Klabnik',
      :site => 'http://steveklabnik.com/'
    }
  }

  def service(*a)
    if last = @env['HTTP_LAST_MODIFIED_SINCE'] and
       Time.parse(last).to_i >= Timeless.options[:last_modified].to_i

      @status = 304
      @body = []
      return self
    end

    @headers['Last-Modified'] = Timeless.options[:last_modified].rfc2822

    super
  rescue NotFound
    @status = 404
    @method = :r404
    super(@env["PATH_INFO"])
  end
end

module Timeless::Controllers
  class Index
    def get
      @headers['Cache-Control'] = 'public, max-age=3600'
      @change = Change.last
      render :index
    end
    
    def main_class; "frontpage" end
  end
  
  class Changelog < R '/changelog'
    def get
      @headers['Cache-Control'] = 'public, max-age=3600'
      @changes = Change.all
      render :changes
    end
  end

  class ChangelogN
    def get(id)
      @headers['Cache-Control'] = 'public, max-age=3600'
      @change = Change.new(id)
      case @change.type
      when :entry
        redirect(@change.url)
      when :text
        render :layout, :layout => false do
          render :_change, :locals => { :change => @change }
        end
      end
    end

    def title; @change.title; end
  end

  class Feed < R '/changelog\.xml'
    def get
      @headers['Content-Type'] = 'text/xml'
      @changes = Change.all.reject { |c| c["feed"] == false }
      render :feed, :layout => false
    end
  end
  
  class Entry < R '/(.+?)'
    def get(name)
      @headers['Cache-Control'] = 'public, max-age=3600'
      @entry = Models::Entry.new(name)

      if @entry.file?
        @headers['Content-Type'] = Rack::Mime.mime_type(File.extname(@entry.name))
        @entry.to_html
      else
        render :entry
      end
    end

    def title; @entry.title; end
  end
end

module Timeless::Helpers
  def main_class; false end

  def entry_index
    entries = Timeless::Models::Entry.all.reject { |e| e.file? or e[:index] == false }
    half = entries.size / 2
    [entries[0...half], entries[half..-1]]
  end
end

w = $stderr.method(:puts)
(class << $stderr; self end).
send(:define_method, :puts) do |*a|
  # SHUT UP MARUKU!
  w.call(*a) unless a.size > 0 && a.first =~ /Bug: /
end

