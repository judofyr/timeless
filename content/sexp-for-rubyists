Title: Sexp for Rubyists
Subtitle: A dialog between a student and his master
Author: judofyr

*Sorry to interrupt you, but you’ve totally lost me. What is this "Sexp"
you’re speaking of? I’ve heard it before, but never quite understood it...*

Oh, don't feel sorry!  It's still quite esoteric for Rubyists.

*Yeah...*

Okay.  Let's start at the beginning.  Lisp!

*With all the parenthesis?*

Bingo!  Have you tried it?

*Not really.  It seems a little too "hardcore", if you know what I mean?*

Ah, yes. It's just a neat little language, nothing to be afraid of. Let me
show you an example:

    (define (plus-five n)
      (+ n 5))
{: lang=scheme }

*It's a method that adds five to the argument?  Like this:*

    def plus_five(n)
      n + 5
    end
{: lang=ruby }

Yep, but more importantly: It's also an example of S-expressions. Because Sexp
is really just a data format.

*Data format?  Like YAML?*

Just like YAML.  It has support for numbers, symbols, pairs, lists and nil.

*Really?*

Let me explain a few more things. You see, Lisp wasn't originally supposed to
be programmed in S-expression. Nope, the idea was to have complex,
human-readable *M-expressions* which should manipulate data in S-expressions.

        Data  =  S-expressions
        Code  =  M-expressions

Another idea was that M-expressions could easily be compiled into
S-expressions. So the computer itself would only work with S-expressions,
while humans could focus on M-expressions.

        M-expressions  -->   S-expressions

However, the first Lisp implementations only accepted S-expressions since it
was easier to start from there and rather add M-expression support later.

*So what happend with these M-expressions?*

They were "receded into the indefinite future" as the creator, John McCarthy,
said. It turned out that S-expressions were readable enough.

*Go on, please.*

Now Lisp suddenly used S-expressions for both code and data. The interesting
thing is how code was represented in Lisp. It's in fact very simple: The first
element in the list is the operator/function and the rest is the
operands/arguments:

    (+ 1 2)
    (plus-five 5)
    (factorial 10)

This makes Lisp a very simple language to implement. You need very few
primitives before you have a fully working Lisp system. In fact, I would
recommend watching James Coglan's screencast. There isn't any audio since he
used it in a talk he gave, but it's still fairy interesting.

<object width="581" height="421"><param name="allowfullscreen" value="true" /><param name="allowscriptaccess" value="always" /><param name="movie" value="http://vimeo.com/moogaloop.swf?clip*id=4339116&amp;server=vimeo.com&amp;show*title=1&amp;show*byline=1&amp;show*portrait=0&amp;color=00ADEF&amp;fullscreen=1" /><embed src="http://vimeo.com/moogaloop.swf?clip*id=4339116&amp;server=vimeo.com&amp;show*title=1&amp;show*byline=1&amp;show*portrait=0&amp;color=00ADEF&amp;fullscreen=1" type="application/x-shockwave-flash" allowfullscreen="true" allowscriptaccess="always" width="581" height="421"></embed></object>

[Scheme interpreter in 15 minutes](http://vimeo.com/4339116) from [James
Coglan](http://vimeo.com/jcoglan) on [Vimeo](http://vimeo.com).

*Wow.  I must definitely check out Lisp.*

Indeed. He's also written a "real" Lisp implementation in Ruby if you're
interested: [Heist][heist]. Oh, and I'll also have to recommend [The Little
Schemer][the-little-schemer] by Daniel P. Friedman and Matthias Felleisen, it
has inspired me in several ways...

*I will, but back to Sexp?*

No.  Let's talk about AST.

*AST? While __I__ certainly appreciate these digressions, (whispers) others
might be a little bored, you know?*

Don't worry, this is pretty essential. An Abstract Syntax Tree is a tree
representation of source code. Compilers and interpreters never work directly
on the source code, but parses it into an AST which is much easier work with.
Your Ruby example above could look something like:

    [Def,
      plus_five
      [n]
      [Call, n, +, [[Lit, 5]]]]

The basic idea here is that we only deal with *nodes* like Def, Call and Lit,
and every node has a set of *children*. In this tree the nodes are built like
this:

    [Def, method_name, arguments, body] # => def method_name(*arguments); body; end
    [Lit, number]                       # => (integer)
    [Call, receiver, method_name, arguments] # => receiver.method_name(*arguments)

*I think I get your point.  This is very similar to S-expressions!*

    (def plus_five (n)
      (call n + 5))

Yes! It turns out that S-expressions are excellent to represent abstract
syntax trees. And when compiler gurus talk about S-expressions, they don't
talk about the file format, they talk about the way Lisp represent it's code:
The first element in the list is the operator/function and the rest are the
operands/arguments.

*So S-expressions themselves aren't very exciting, it all depends on what you
put in them?*

Exactly.  The Sexp-class basically looks like this:

    class Sexp < Array
      def sexp_type
        self[0]
      end
      
      def sexp_body
        self[1..-1]
      end
    end
{: lang=ruby }

A glorified Array.  That's all there is to it.

*And what do people put in these Sexps?*

Let me show you an example. First, `gem install ruby_parser`. Then:

    require 'ruby_parser'
    require 'pp'

    pp RubyParser.new.parse(<<-EOF)
      def plus_five(n)
        n + 5
      end
    EOF
{: lang=ruby }

*Interesting:*

    s(:defn,
     :plus_five,
     s(:args, :n),
     s(:scope,
       s(:block,
         s(:call, s(:lvar, :n), :+, s(:arglist, s(:lit, 5))))))

This is the *syntatic* strucure of our code. It's not possible to reconstruct
the original snippet character-by-character; you only get what the
compiler/interpreter/virtual machine actually sees. And often that's exactly
the only thing we want.

*Aha.  Who decided this structure and these names by the way?*

Well, I'm not quite certain, but I believe ParseTree by Ryan Davis started it
all.

*Oh, ParseTree sounds familiar.*

It extracts the raw AST that Ruby 1.8 uses internally. It's not very elegant,
so Ryan also wrote UnifiedRuby which cleans it up a bit. RubyParser returns
such a cleanup up Sexp.

*And what do people use these cleaned up Sexps for?*

There's plenty of projects floating around, here's some I've heard of:

* [Flog](http://ruby.sadi.st/Flog.html) analyzes your code and shows how complex your methods are, and which you should refactor.
* [Flay](http://ruby.sadi.st/Flay.html) analyzes your code for structural similarities, ready to be DRYed out!
* [Roodi](http://github.com/martinjandrews/roodi) warns you about design issues.
* [Reek](http://github.com/kevinrutherford/reek) detects code smells.
* [Saikuro](http://saikuro.rubyforge.org/) is a "cyclomatic complexity analyzer".
* [Ambition](http://ambition.rubyforge.org/) let's you write SQL statements as Ruby blocks.
* [Parkaby](http://github.com/judofyr/parkaby) compiles Markaby-like code into super-fast code.
* [RewriteRails](http://github.com/raganwald/rewrite*rails) adds syntactic abstractions (like Andand) to Rails projects without monkey-patching.

*Cool, that's more than I thought.*

And if more people knew about them, I guess there would be even more.

*Let me recap:*

*For Rubyists, Sexp is an Array-ish list where the first element is the
operator/function and the rest is the operands/arguments. The arguments can
also contain other Sexp. When I think about it, that's probably the most
important thing: They are nested.*

*I guess it's mostly useful when we're actually manipulating code that
executes. Like source code or templates?*

Exactly!

*Ah, excellent.  Why were we talking about Sexps again?*

Hm.. Now that's a good question. I simply don't remember. Let's talk about it
another time, shall we?

[heist]: http://github.com/jcoglan/heist
[the-little-schemer]: http://www.ccs.neu.edu/home/matthias/BTLS/
