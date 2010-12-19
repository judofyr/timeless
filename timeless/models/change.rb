module Timeless::Models
  class Change
    CONTINUE = '<p><a href="%s">Continue to full post.</a></p>'
    UPDATED = CONTINUE.sub('full', 'updated')
    ALL = Dir["changes/*.yaml"].map { |x| x[/\d+/].to_i }.sort
    LAST = ALL.last

    attr_reader :id

    def self.last
      new(LAST)
    end

    def self.all(options = {})
      limit = (options[:limit] || 0) - 1
      ALL.reverse.map { |x| new(x) }
    end

    def initialize(id)
      @id = id.to_i
      raise NotFound unless exists?
    end

    def filename; "changes/#{@id}.yaml"; end
    def exists?; File.exists?(filename) end

    def content
      @content ||= YAML.load_file(filename)
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

    def to_full_html
      case type
      when :entry
        entry.to_html
      when :update
        to_html
      when :text
        to_html
      end
    end

    def to_html
      case type
      when :entry
        entry.to_snip + (CONTINUE % full_url)
      when :update
        htmlize(:update) + (UPDATED % full_url)
      when :text
        htmlize(:text)
      end
    end
    
    def full_url
      "http://timeless.judofyr.net#{url}"
    end

    def url
      if type == :text
        "/changelog/#{@id}"
      else
        "/#{entry.name}"
      end
    end

    def entry
      @entry ||= Entry.new(content["entry"])
    end

    def htmlize(field)
      Maruku.new(content[field.to_s]).to_html
    end
  end
end

