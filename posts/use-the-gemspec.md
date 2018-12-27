Title: Use the Gemspec
Author: judofyr

You can say a lot about GitHub's [previous gem hosting][gh-gem], but at
least it helped us understanding one thing: the value of a gemspec. The
gemspec is the README of the bits and the bytes of your code. It can both
be understood and changed by both computers and humans. We shouldn't fear
the gemspec; we should embrace it.

Storing the data in the Rakefile and generating the gemspec seems totally
backwards to me. Rakefile is for tasks, let's place the data where it
belongs: **in the gemspec**. Instead of building tools which generates the
gemspec, let's build tools that *uses* the gemspec.

Like `gem build rails.gemspec`.

Like the newest [Gemify][gemify]:

    $ gemify
    Currently editing gemify.gemspec

    Which task would you like to invoke?
    1) Change name (required) = gemify
    2) Change summary (required) = The lightweight gemspec editor
    3) Change version (required) = 0.3
    4) Change author = Magnus Holm
    5) Change email = judofyr@gmail.com
    6) Change homepage = http://dojo.rubyforge.org/
    7) Set dependencies

    s) Save
    r) Reload (discard unsaved changes)
    m) Rename
    l) List files

    x) Exit

<hr>

It's not a solved problem though.

Rubygems can read any gemspec with Gem::Specification.load, but can only
write it back again with #to_ruby in a normalized version.

Let's have a look at [Bundler's excellent gemspec][yehuda]:

    # -*- encoding: utf-8 -*-
    lib = File.expand_path('../lib/', __FILE__)
    $:.unshift lib unless $:.include?(lib)

    require 'bundler/version'

    Gem::Specification.new do |s|
      s.name        = "bundler"
      s.version     = Bundler::VERSION
      s.platform    = Gem::Platform::RUBY
      s.authors     = ["Carl Lerche", "Yehuda Katz", "André Arko"]
      s.email       = ["carlhuda@engineyard.com"]
      s.homepage    = "http://github.com/carlhuda/bundler"
      s.summary     = "The best way to manage your application's dependencies"

      s.required_rubygems_version = ">= 1.3.6"
      s.rubyforge_project         = "bundler"

      s.add_development_dependency "rspec"

      s.files        = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md ROADMAP.md CHANGELOG.md)
      s.executables  = ['bundle']
      s.require_path = 'lib'
    end
{: lang=ruby }

Short and concise. After running it through `Gem::Specification.load(file)
to_ruby`:

    # -*- encoding: utf-8 -*-

    Gem::Specification.new do |s|
      s.name = %q{bundler}
      s.version = "0.10.pre"

      s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
      s.authors = ["Carl Lerche", "Yehuda Katz", "Andr\303\251 Arko"]
      s.date = %q{2010-04-03}
      s.default_executable = %q{bundle}
      s.email = ["carlhuda@engineyard.com"]
      s.executables = ["bundle"]
      s.files = %w[one huge array]
      s.homepage = %q{http://github.com/carlhuda/bundler}
      s.require_paths = ["lib"]
      s.rubyforge_project = %q{bundler}
      s.rubygems_version = %q{1.3.6}
      s.summary = %q{The best way to manage your application's dependencies}

      if s.respond_to? :specification_version then
        current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
        s.specification_version = 3

        if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
          s.add_development_dependency(%q<rspec>, [">= 0"])
        else
          s.add_dependency(%q<rspec>, [">= 0"])
        end
      else
        s.add_dependency(%q<rspec>, [">= 0"])
      end
    end
{: lang=ruby }

Boom, there goes your nice VERSION constant. And no more Dir globbing for
you.

<hr>

We need to make it possible to write interactive gemspec (heck, that's why
they are written in Ruby!) **and** make them easily readable by computers 
**and** make them easily *modified* by computers without losing the
interactivity.

Anyone?

[gh-gem]: http://github.com/blog/515-gem-building-is-defunct
[gemify]: http://dojo.rubyforge.org/gemify
[yehuda]: http://yehudakatz.com/2010/04/02/using-gemspecs-as-intended/
