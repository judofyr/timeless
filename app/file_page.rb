require_relative 'page'

class FilePage < Page
  route do |r, page|
    r.get true do
      response["Content-Type"] = page.content_type
      page.content
    end
  end

  def ext
    @path.extname.to_s
  end

  CONTENT_TYPES = {
    ".html" => "text/html; charset=utf-8"
  }

  def content_type
    CONTENT_TYPES.fetch(ext, "text/plain")
  end

  def content
    @content ||= @path.read
  end
end

