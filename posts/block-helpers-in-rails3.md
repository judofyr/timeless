Title: Block Helpers in Rails 3
Subtitle: Wherein Rails add their own ERB syntax
Author: judofyr

In May 2010 I attended [Frozen Rails][frozenrails] in Helsinki where Carl
Lerche held a talk about Rails 3. Like everything else regarding Rails 3
it wasn't a _revolutionary_ talk, but I rather found myself nodding "Yep,
that's a better solution" every now and then (which after all is the
whole idea of Rails 3).

When it comes to block helpers in ERB however, I wasn't quite so
positive. Block helpers have always been a little confusing in Rails -
both their usage and their implementation. Rails 3 attempts to clean them
up, but at what cost?

(snip)

## Rails 2.3

This shows the regular usage of block helpers in Rails 2.3:

    <% form_for @post do |f| %>
      <%= f.text_field :title %>
    <% end %>

    <% box do %>
      <p>Hello World!</p>
    <% end %>
{: lang=erb }

It's what we're used to and it probably seems completely fine to most of
us, but when you think about it, it's not really consistent. Both the
form_for and the f.text_field output HTML, but only the latter uses ERB's
output syntax. The block helper magically outputs the content itself:

    def box(&block)
      content = "<div class='box'>" + capture(&block) + "</div>"
      
      if block_called_from_erb?(block)
        concat(content)
      else
        content
      end
    end
{: lang=ruby }

Notice the `block_called_from_erb?(block)`. If the method was called
inside of ERB, it automagically concats the string to the result. If
box is called somewhere else, it just returns the string. 
There's tons of these checks in Rails 2.3, and they're not pretty
(especially not the implementation of block_called_from_erb?)

## Rails 3

Here's the same example in Rails 3:

    <%= form_for @post do |f| %>
      <%= f.text_field :title %>
    <% end %>

    <%= box do %>
      <p>Hello World!</p>
    <% end %>
{: lang=erb }

Notice how it's consistent with ERB. Both form_for and f.text_field
output HTML, and both of them uses ERB's output syntax. Therefore, the
implementation is much simpler:

    def box(&block)
      "<div class='box'>" + capture(&block) + "</div>"
    end
{: lang=ruby }

Everything is much simpler and prettier. I bet you're wondering: "Why so
negative?"

## It's no longer ERB

It's no longer ERB. When you use this _extension_, you're not writing ERB
anymore. You're writing Rails ERB. `<%= box do %>` is simply not valid
ERB. While there's no written spec for ERB, there are some basic rules
which every implementation of ERB can follow.

The first rule is that the expression in `<%= =%>` must be a *complete
expression* [^c-expr]. A complete expression is an expression which you can
pass directly into eval without getting a syntax error. Or you could say
that it's a piece of Ruby code which you can place *parenthesis* around
and it still ends up as valid Ruby:

    eval("f.text_field")  # => Works fine
    ( f.text_field )      # => Valid
    
    eval("box do")        # => SyntaxError
    ( box do )            # => Invalid
{: lang=ruby }

The expression in `<% %>` on the other hand only needs to be a
*subexpression*. A subexpression is something which by itself is an invalid
expression, but becomes valid if there's another subexpression below
or above it which completes it. You could also say that it's a piece
of Ruby code which you can place *semicolons* around:

    eval("box do")    # => SyntaxError
    ; box do ;        # => Valid (as long as there is an `end` later)

As you can see, `box do` is a subexpression, but not a complete
expression. Therefore, in normal ERB, you can put it inside `<% %>`, but
not `<%= %>`.

## Why is there a difference?

Now you're probably wondering *why* there is a difference between `<%=
%>` and `<% %>`. Couldn't just both accept a subexpression? In order to
understand this issue, we'll have to look at how ERB generates code.

Given this code:

    <% form_for @post do |f| %>
      <%= f.text_field :title %>
    <% end %>

    <% box do %>
      <p>Hello World!</p>
    <% end %>
{: lang=erb }

ERB generates this code:

    _buffer = ""
    form_for @post do |f|
      _buffer << (f.text_field :title).to_s
    end
    
    box do
      _buffer << ("<p>Hello World!").to_s
    end
{: lang=ruby }

As you can see, it needs to convert the expressions to strings in
order to concat it to the buffer. It's not always about converting to
strings though; in some cases you might for instance want to wrap it within
another method call (like `CGI.escapeHTML` to prevent XSS attacks).

It's not technically possible to do this with *all* subexpressions:

    _buffer << ( box do ).to_s
      _buffer << ("<p>Hello World!</p>").to_s
    end
{: lang=ruby }

## Impossible? But it works in Rails 3!

Let's have a look at how it's implemented in Rails 3:

    # in actionpack/lib/action_view/template/handlers/erb.rb
    class ActionView::Template::Handlers::Erubis < Erubis::Eruby
      BLOCK_EXPR = /\s+(do|\{)(\s*\|[^|]*\|)?\s*\Z/

      def add_expr_literal(src, code)
        if code =~ BLOCK_EXPR
          src << '@output_buffer.append= ' << code
        else
          src << '@output_buffer.append= (' << code << ');'
        end
      end
{: lang=ruby }

It's basically one big hack. It uses a *regular expression* for
figuring out whether or not an expression is a block expression. Then
it has to use a fake write attribute (`alias :append= :<<`) so it
doesn't need to wrap the code in parenthesis.

One big, fragile hack which breaks easily:

    # A valid Ruby expression, but invalid Rails ERB.
    <%= article do |a| m = a.metadata %>
      Written by: <%= m[:author] %>
      <%= a.content %>
    <% end %>
{: lang=erb }

## Conclusion

**Yes**, I agree that block helpers are ugly in Rails 2.3.

**No**, In Rails 3 you're not writing ERB; you're writing Rails ERB,
RERB, ERB-with-funky-hacky-block-helpers-thingie or whatever you want
to call it. It's still not ERB.

The fact that Rails still claims it uses ERB is what makes me
uncomfortable. They're silently chainging the behaviour of ERB, but
currently it only sort-of works in a single framework (Rails) with a
single ERB implementation (Erubis).

Just because ERB itself isn't formally spec'ed somewhere, doesn't mean
you can modify it your own needs and still claim it to be ERB. I fear
that we're ending up with two "versions" of ERB which will be
confusing for both those writing the ERB templates, those who want to
include ERB support and those who maintains an ERB implementation.

[^c-expr]: The reason you haven't heard about a complete expression
before is because I came up with the term. Please [let me
know](/comments) if you have a better suggestion or know the
"official" name for it. 

[frozenrails]: http://frozenrails.eu/
