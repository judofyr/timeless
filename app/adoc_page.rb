require 'asciidoctor'
require 'asciidoctor-html5s'
require 'asciidoctor-rouge'
require_relative 'page'

class AdocPage < Page
  route do |r, page|
    r.get true do
      @layout.title = page.title
      @layout.body = page
      render_layout
    end
  end

  def key
    @key ||= @path.basename(".adoc").to_s
  end

  def doc
    @doc ||= Asciidoctor.load_file(
      @path,
      safe: 0,
      backend: 'html5s',
      attributes: {'source-highlighter' => 'rouge' },
    )
  end

  def title
    doc.doctitle
  end

  def content
    @content ||= doc.render
  end

  def to_tubby
    Tubby.new { |t|
      t.article(class: "post") {
        t.header {
          t.h1(title)
          t.p {
            t << "Written by "
            t << doc.author
          }
        }
        t.raw!(content)
      }
    }
  end
end

