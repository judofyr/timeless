class Change
  CONTINUE = '<p><a href="%s">Continue to full post.</a></p>'
  UPDATED = CONTINUE.sub('full', 'updated')

  attr_reader :path

  def initialize(path)
    @path = path
  end

  def id
    @id ||= path.to_s[/(\d+)\.yaml$/, 1].to_i
  end

  def content
    @content ||= YAML.load_file(path)
  end

  def [](key); content[key.to_s]; end
  def created_at
    c = self["created_at"]
    c.is_a?(String) ? Time.parse(c) : c
  end

  def type
    if content.has_key?("update")
      :update
    elsif content.has_key?("entry")
      :entry
    else
      :text
    end
  end

  def title
    case type
    when :entry
      entry.title
    when :update
      "Updated: " + entry.title
    when :text
      content["title"]
    end
  end
  
  # Returns a full HTML which can be included in i.e. a feed.
  def to_full_html
    case type
    when :entry
      if entry[:link]
        # It's actually a link, so we want "Continue to"
        to_html
      else
        entry.html
      end
    else
      to_html
    end
  end

  def to_html
    case type
    when :entry
      entry.snip_html + (CONTINUE % full_url)
    when :update
      htmlize(:update) + (UPDATED % full_url)
    when :text
      htmlize(:text)
    end
  end
  
  def full_url
    if url[0] == ?/
      "http://timelessrepo.com#{url}"
    else
      url
    end
  end

  def url
    if type == :text
      "/changelog/#{@id}"
    else
      entry.link
    end
  end

  def entry
    @entry ||= Timeless.main.lookup_page(self["entry"])
  end

  def htmlize(field)
    Maruku.new(content[field.to_s]).to_html
  end

  def to_tubby
    Tubby.new { |t|
      t.article(class: "post") {
        t.header {
          t.h1(title)
          t.p
        }

        t.raw!(to_html)
      }
    }
  end
end

