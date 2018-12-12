class Page
  class << self
    def route(&blk)
      @route = blk if blk
      @route ||= proc { }
    end
  end

  def route
    page = self
    @route ||= proc { |r| instance_exec(r, page, &page.class.route) }
  end

  def initialize(path)
    @path = path
  end

  def key
    @key ||= @path.basename.to_s
  end

  def link
    "/#{key}"
  end

  def title
  end

  def subtitle
  end
end

