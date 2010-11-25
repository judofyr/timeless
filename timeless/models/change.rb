module Timeless::Models
  class Change
    CONTINUE = '<p><a href="%s">Continue to full post.</a></p>'
    UPDATED = CONTINUE.sub('full', 'updated')

    attr_reader :id

    def self.last
      new(Dir["changes/*.yaml"].sort.last[/\d+/])
    end

    def self.all(options = {})
      limit = (options[:limit] || 0) - 1
      Dir["changes/*.yaml"].sort.reverse[0..limit].map { |c| new(c[/\d+/]) }
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
    def created_at; Time.parse(self["created_at"]) end

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
        entry.to_snip + (CONTINUE % url)
      when :update
        htmlize(:update) + (UPDATED % url)
      when :text
        htmlize(:text)
      end
    end

    def url
      if type == :text
        "http://timeless.judofyr.net/changelog/#{@id}"
      else
        "http://timeless.judofyr.net/#{entry.name}"
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

