class Index
  def initialize
    @sections = []
    @pages = Timeless.main.pages.select(&:title)
    @remaining_pages = {}
    @pages.each do |page|
      @remaining_pages[page.key] = page
    end

    build_index
  end

  def build_index
    page_section(
      "Programming pieces",
      [
        "composing-templates-with-tubby",
        "abstraction-creep",
        "json-isnt-a-javascript-subset",
        "literate-programming",
        "mockup-driven-development",
        "haters-gonna-hateoas",
        "cracking-tootsweets-masyu-format",
      ],
      color: "blue",
    )

    page_section(
      "Thoughts",
      [
        "there-is-no-talent",
        "why-there-is-no-talent",
        "your-blog-is-a-project",
        "simplicity-is-difficult",
      ],
      color: "indigo",
      text: <<~EOF
      Let's be honest: These aren't exactly Nietzsche. They made sense when they were written though.
      EOF
    )


    page_section(
      "Ruby pieces",
      [
        "sexp-for-rubyists",
        "tailin-ruby",
        "when-in-doubt",
        "bdd-with-rspec-and-steak",
        "on-camping-vs-sinatra",
        "making-ruby-gems",
        "refinements-in-ruby",
        "block-helpers-in-rails3",
        "building-a-website-with-webby",
      ],
      color: "red",
      text: <<~EOF
      Specialized for Rubyists.
      EOF
    )

    page_section(
      "Ruby bits",
      [
        "copy-paste",
        "never-gonna-let-you-go",
        "morse",
        "nokogirl",
        "chained-comparisons",
        "charging-objects-in-ruby",
        "tribute",
        "haiku",
        "superio"
      ],
      color: "pink",
      text: <<~EOF
      Small bits of Ruby. Something to chew on. 80% fun, 90% useless.
      EOF
    )

    page_section(
      "Old Projects",
      [
        "gash",
        "parkaby",
        "grancher",
        "sexp-builder",
        "use-the-gemspec",
      ],
      color: "brown",
      text: <<~EOF
      Ahh. All of the projects which was once so promising, but is now
      completely left alone. Who knows if they still work? Who knows if anyone
      is using them?
      EOF
    )

    page_section(
      "Projects that's still alive",
      [
        "temple",
      ],
      color: "green",
    )

    page_section(
      "Meta",
      [
        "timeless",
        "comments",
        "contribute",
      ],
      color: "gray"
    )

    page_section("The Rest", @remaining_pages.keys)
  end

  def page_section(name, keys, color: nil, text: nil)
    pages = keys.map do |key|
      if !@remaining_pages.has_key?(key)
        raise ArgumentError, "No such page: #{key}"
      end
      @remaining_pages.delete(key)
    end

    @sections << Tubby.new { |t|
      t.div(class: "front-section") {
        t.h2 {
          t.span(name, style: ("border-color: #{color}" if color))
        }

        t.markdown!(text) if text

        yield t if block_given?

        t.ol(class: "front-index") {
          pages.each do |page|
            t.li {
              t.a(page.title, href: page.link)
              if page.subtitle
                t.span(page.subtitle, class: "extra")
              end
            }
          end
        }
      }
    }
  end

  def to_tubby
    Tubby.new { |t|
      @sections.each do |section|
        t << section
      end
    }
  end
end

