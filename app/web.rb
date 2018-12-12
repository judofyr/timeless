require 'roda'
require_relative 'timeless'
require_relative 'layout'
require_relative 'index'
require 'tubby'

class Renderer < Tubby::Renderer
  def markdown!(str)
    raw! Maruku.new(str).to_html
  end
end

HTMLSafe = Struct.new(:to_html)

class Web < Roda
  T = Timeless.main

  opts[:root] = __dir__
  plugin :assets, css: 'style.css'
  plugin :render

  def render_layout
    target = String.new
    t = Renderer.new(target)
    t << @layout
    target
  end

  route do |r|
    r.assets

    @layout = Layout.new
    @layout.push_head(HTMLSafe.new(assets(:css)))

    r.root do
      @layout.big_header = true
      @layout.body = Index.new
      render_layout
    end

    r.is 'changelog.xml' do
      @changes = T.changes
      response['Content-Type'] = 'text/xml'
      render(:feed)
    end

    r.is 'changelog', Integer do |id|
      if change = T.changes.detect { |c| c.id == id }
        @layout.title = change.title
        @layout.body = change
        render_layout
      end
    end

    r.is String do |key|
      if page = T.lookup_page(key)
        instance_exec(r, &page.route)
      end
    end
  end
end

