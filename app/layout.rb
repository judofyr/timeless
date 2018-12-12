require 'tubby'

class Layout
  attr_accessor :title, :body, :big_header

  def initialize
    @title = nil
    @body = nil
    @big_header = false
    @head = []
  end

  def push_head(text)
    @head << text
  end

  def to_tubby
    Tubby.new { |t|
      t.doctype!
      t.html {
        t.head {
          t.meta(charset: "utf-8")
          t.meta(name: "viewport", content: "width=device-width, initial-scale=1")
          t.title {
            t << "#{@title} - " if @title
            t << "Timeless"
          }

          t.link(rel: "stylesheet", href: "https://fonts.googleapis.com/css?family=PT+Serif:400,700")

          @head.each do |text|
            t << text
          end
        }

        t.body {
          t.header(class: ["header", ("header-big" if @big_header)]) {
            t.h1 {
              t.a(href: "/") {
                t << "The "
                t.strong("timeless")
                t << " repository"
              }
            }
          }

          t.div(class: "main") {
            t << @body

            t.div(class: "footer") {
              t << Time.now.year
              t << " — "
              t << 'All content is licensed under '
              t.a("CC BY-SA 3.0", href: "http://creativecommons.org/licenses/by-sa/3.0/")
            }
          }
        }
      }
    }
  end
end
