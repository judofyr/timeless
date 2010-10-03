module Timeless::Models
  class Change
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
      content.has_key?("entry") ? :entry : :text
    end

    def title
      type == :entry ? entry.title : content["title"]
    end

    def to_html
      type == :entry ? entry.to_snip : Maruku.new(content["text"]).to_html
    end

    def url
      type == :entry ? "/#{entry.name}" : "/changelog/#{@id}"
    end

    def entry
      @entry ||= Entry.new(content["entry"])
    end
  end
end

