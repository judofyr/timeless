require 'maruku'
require_relative 'page'
require_relative '../maruku-rouge'

class PostPage < Page
  route do |r, page|
    r.get true do
      @layout.title = page.title
      @layout.body = page
      render_layout
    end
  end

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

  def key
    @key ||= @path.basename(".md").to_s
  end

  def [](key);  maruku.get_setting(key) end

  def maruku
    @maruku ||= Maruku.new(content)
  end

  def html
    @html ||= maruku.to_html
  end

  def snip_html
    @snip_html ||= Maruku.new(content(true)).to_html
  end

  def title
    self[:title]
  end

  def subtitle
    self[:subtitle]
  end

  def author?
    self[:author]
  end

  def link
    self[:link] || super
  end

  def author
    @author ||= Authors.fetch(self[:author])
  end

  def author_name
    author.fetch(:name)
  end

  def author_site
    author.fetch(:site)
  end

  def last_updated
    str = self[:last_updated]
    str && Time.parse(str)
  end

  def content(snip = false)
    content = @path.read
    if snip
      content =~ /\(snip\)/
      $` || content
    else
      content.gsub('(snip)', '')
    end
  end

  def to_tubby
    Tubby.new { |t|
      t.article(class: "post") {
        t.header {
          t.h1(title)


          if author?
            t.p {
              t << "Written by "
              t.a(author_name, href: author_site)
            }
          end
        }

        t.raw!(html)
      }
    }
  end
end

