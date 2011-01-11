module Timeless::Models
  class Entry
    attr_reader :name

    def self.all
      @all ||= entries.map { |name| new(name, true) }
    end

    def self.entries
      Dir["content/*"].reject { |f| f =~ /~/ }.map { |f| File.basename(f) }
    end

    def self.new(name, force = false)
      if force
        super(name)
      else
        all.detect { |e| e.name == name } or raise NotFound
      end
    end

    def initialize(name)
      @name = name
      raise NotFound unless exists?
    end

    def to_param; @name end
    def <=>(o);   title <=> o.title end
    def filename; "content/#{@name}" end
    def file?;    @name.include?(".") end
    def exists?;  File.exists?(filename) end
  
    def to_html
      file? ? content : (@html ||= maruku.to_html)
    end
  
    def title
      file? ? @name : maruku.get_setting(:title) || @name
    end

    def subtitle
      file? ? "" : maruku.get_setting(:subtitle) || ""
    end
    
    def author
      maruku.get_setting(:author) unless file?
    end
    
    def last_updated
      if defined?(@last_updated)
        @last_updated
      else
        str = maruku.get_setting(:last_updated)
        @last_updated = Time.parse(str)
      end
    end

    def to_snip
      Maruku.new(content(true)).to_html
    end

    def content(snip = false)
      content = File.read(filename)
      if snip
        content =~ /\(snip\)/
        $` || content
      else
        content.gsub('(snip)', '')
      end
    end
  
    def maruku
      @maruku ||= Maruku.new(content)
    end
  end
end
