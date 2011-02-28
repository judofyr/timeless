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

    def url
      if entry? and link = self[:link]
        link
      else
        "/#{@name}"
      end
    end
        
    def <=>(o);   title <=> o.title end
    def filename; "content/#{@name}" end
    def file?;    @name.include?(".") end
    def entry?;   not file? end
    def exists?;  File.exists?(filename) end
    def [](key); maruku.get_setting(key) end
  
    def to_html
      file? ? content : (@html ||= maruku.to_html)
    end
  
    def title
      file? ? @name : self[:title] || @name
    end

    def subtitle
      file? ? "" : self[:subtitle] || ""
    end
    
    def author
      Timeless::Authors[self[:author]] unless file?
    end
    
    def last_updated
      str = self[:last_updated]
      str && Time.parse(str)
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
