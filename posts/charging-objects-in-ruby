Title: Charging Objects in Ruby
Subtitle: Positive, negative and whatnot
Author: judofyr

Today we'll explore a not so widely used feature in Ruby: overriding the the
unary operators for fun and profit:

    class CustomTimeless < Script
      # This script applies to every page:
      + url("http://timeless.judofyr.net/*")
      # ... except the front page:
      - url("http://timeless.judofyr.net/")
      # ... or the changelog:
      - url("http://timeless.judofyr.net/changelog/*")
      # ... and only HTML files:
      + type("text/html")
      
      def process(html)
        # Do funky thing with the HTML
      end
    end
{: lang=ruby }

This must be one of the coolest, yet quite unknown, technique in Ruby. For
certain types of problems (e.g. when you have a set of rules) this gives you
such an elegant way of describing the solution. There's no meta programming
or monkey patching involved, it's short and sweet and best of all: it's very
intuitive.

Let's have a look at this and a few other tricks you can do by overriding the
unary operators.

(snip)

## You can overload the unary operators???

    a = 5
    b = -a
    c = +a
    d = ~a
    e = !a
{: lang=ruby }

You probably already know that it's possible to override pretty much any
operator in Ruby, so why should unary operators be treated differently? It
makes very much sense when you think about it, but for some reason, most
Rubyists never think about it. Unary operators just seems like a part of the
language. Time for some myth busting, eh?

    class Rule
      attr_accessor :type, :value, :charge
      
      def initialize(type, value)
        @type = type
        @value = value
        @charge = :neutral
      end
      
      def +@
        @charge = :positive
        self
      end
      
      def -@
        @charge = :negative
        self
      end
      
      def ~@
        @charge = :neutral
        self
      end
    end
{: lang=ruby }

Woah, woah, woah. Hang on a second. `+@`? `-@`? `~@`? What's the matter with
these weird method names? Let's fire up IRB and see:
    
    >> r = Rule.new(:url, "http://timeless.judofyr.net/*")
    => #<Rule:0x1003599f8 @value="http://timeless.judofyr.net/*", 
         @charge=:neutral, @type=:url>
    
    >> r.charge
    => :neutral
    
    >> r.-@()
    >> r.charge
    => :negative
    
    >> +r
    >> r.charge
    => :positive
    
    >> "+(binary)".to_sym
    => :+
    
    >> "+(unary)".to_sym
    => :+@
{: lang=ruby }

Like any other method, you can call them the usual way (`r.-@()`), but it
*also* turns out that Ruby uses these methods internally for the unary
operators:

    >> a = 1
    >> -a
    => -1
    >> a.-@()
    => -1
{: lang=ruby }

So how can we (ab)use these methods?

## Example: Proxy with HTML rewriting support

Once upon a time there was a [Ruby proxy][mH] which worked pretty much like
Greasemonkey: You could easily modify any page *before* it hit the browser.
By using the unary operators you could create scripts and define which pages
it should rewrite:

    class CustomTimeless < MouseHole::Script
      # This script applies to every page:
      + url("http://timeless.judofyr.net/*")
      # ... except the front page:
      - url("http://timeless.judofyr.net/")
      # ... or the changelog:
      - url("http://timeless.judofyr.net/changelog/*")
      # ... and only HTML files:
      
      def process(html)
        # Do funky thing with the HTML
      end
    end
{: lang=ruby }

How does it work? Simply take the Rule class above and combine it with this:

    class MouseHole::Script
      def self.rules
        @rules ||= []
      end
      
      def self.url(value)
        rule = Rule.new(:url, value)
        rules << rule
        rule
      end
    end
{: lang=ruby }

Now you just need to loop through the rules to figure out if an URL matches
or not. Ta-da!

## Terrible Example: Negaposi

    class                                                  NP
    def  initialize a=@p=[], b=@b=[];                      end
    def +@;@b<<1;b2c end;def-@;@b<<0;b2c                   end
    def  b2c;if @b.size==8;c=0;@b.each{|b|c<<=1;c|=b};send(
         'lave'.reverse,(@p.join))if c==0;@p<<c.chr;@b=[]  end
         self end end ; begin _ = NP.new                   end
    
    +-+--++----+--+--+---+-------+--++--+++---+-+++-+-+-+++-----+++-_
    --++-++--+--+++-++++-++-+++-+-+------+--++++-++---++-++---++-++-_
    ---------+-+-----+---+--+----+----+--++-                        _
{: lang=ruby }

Who needs Ruby syntax when you have plus and minus? [Negaposi][np] gives you
everything you need!

## It get's even better!

In Ruby 1.9, it gets even better: We can redefine the `not` operator too:

    class Rule
      attr_accessor :priority
      
      def initialize
        @priority = 0
      end
      
      # (Only possible in 1.9)
      def !
        @priority += 1
        self
      end
    end
    
    class Something < Script
      # !!! VERY IMPORTANT !!!
      !!! + url("http://timeless.judofyr.net/*")
    end
{: lang=ruby }

## Horrible Example: MaybeNot (1.9 only)

    class Object
      def !; rand(2).zero? end
    end unless ENV["USER"] == "magnus"
{: lang=ruby }

"Sorry, mate. I can't reproduce the error on my machine."

## Your turn

I'd love to see what you can (ab)use this for. Please [let me
know](/comments) if you find a suitable usage, and I'll update this article.

[mH]: https://github.com/evaryont/mousehole
[np]: http://www.namikilab.tuat.ac.jp/~sasada/diary/200505.html#d10
