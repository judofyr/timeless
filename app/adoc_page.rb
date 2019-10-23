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

  def review_date
    @review_date ||=
      if str = doc.attributes["review-date"]
        Date.parse(str)
      end
  end

  def stale_content?
    !!doc.attributes["review-stale"]
  end

  OUT_OF_DATE = 200

  def stale_review?
    if rd = review_date
      Date.today - rd > OUT_OF_DATE
    else
      true
    end
  end

  def to_tubby
    Tubby.new { |t|
      t.article(class: "post") {
        t.header {
          t.h1(title)
          t.p {
            t << "Written by "
            t << doc.author
            t << ". "

            if rd = review_date
              t << "Last updated "
              t << rd.strftime("%B %-d, %Y")
              t << ". "
            end
          }
        }

        if stale_content?
          t.div(class: "alert error") {
            t.p {
              t.strong("Note: ")
              t << "The following content is known to be out of date. "
              t << "You might still find it useful, but be aware. "
            }
          }
        elsif stale_review?
          t.div(class: "alert warning") {
            t.p {
              t.strong("Note: ")
              t << "The following content hasn't been reviewed in a while and it might be out of date. "
            }
          }
        end

        t.raw!(content)
      }
    }
  end
end

