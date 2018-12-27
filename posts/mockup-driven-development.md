Title: Mockup-Driven Development
Subtitle: When mockups and templates combine forces
Author: judofyr

Design in web development is usually accomplished in three main steps:

1. Concept
2. Mockup
3. Template

Mockup-Driven Development attempts to merge the last two in order to make it
easier to **build**, **maintain** and **experiment** with your application.
Let's have a look at some of the real issues present in today's workflow and
how MDD tries to solve them. We'll also check out the current
implementations, what issues they have and how we can improve them.

(snip)

## The Steps
### Step 1: Concept

I'm not going to focus on the first step at all, so let's just define it as
*everything that is done before you have a mockup in HTML*. That includes
sketches, Photoshop mockups, and so on.

### Step 2: Mockup (in HTML)

The next step is to create some HTML so you can actually see how the site
would end up. It's all static files and nothing is functional, but you can at
least get a feeling about what works and what you need to improve on. More
importantly, mockups are a direct step on the path to a functional
application: This is actually a concrete product which will be used later on.

### Step 3: Template

The last step is to integrate the mockups with the rest of the application in
order to Make Things Work™. Usually this involves annotating the HTML where
the dynamic data should be inserted. I like to think about it as punching out
"holes" which you'll fill out with data at every request.

## The Workflows

Most web application will, at least to some extent, go through these three
steps and in order to get the best result you want to have the most skilled
people working at each step: A *designer* works on the concept, a *web
designer* knows how to turn it into a mockup and a *developer* makes it work.

I'll focus mostly on the workflow between the mockups and the templates.

### Separate mockups and templates

One workflow is that the web designer *only* works with the mockups while the
developer *only* works with the templates. Every time there is a change in
the mockups (or the templates for that matter), you'll have to remember to
keep the two sets of files in sync.

There's one big advantage of this workflow: The web designer can continue
working on the application in the *exactly* same way throughout the process.
The great thing about this process is that **it's only static files**: You
can easily view them in *any* browser on *any* computer and you don't need to
have the application running in order to view the final result.

A disadvantage with this approach is that mockups are **horrible to
maintain**. There's no layouts or partials, so if the web designer wants to
change something that's shared among all the pages, he'll have to update
*all* the pages. You might use something like Dreamweaver's template
functionality to solve this issue, but now you've locked everyone into using
a single tool.

And of course, now that you have two sets of the design you'll constantly
need to **keep them in sync**. Every change in the mockup needs to be
reflected in the template (and the other way around). This means that while
it's super easy to experiment at each of the steps, you'll end up with a
massive merging process at the end of each iteration.

### Everyone works on the template

Because of the disadvantages of the approach above, most people have a little
different workflow. This is for instance the way [37signals][dhh-workflow]
works:

> This is how we work:
> 
> 1. Designer cooks up static HTML template.
> 2. Programmer sprinkle it with ERB tags to make the dynamic elements 
>    dynamic.
> 3. Designer and programmer can both revisit the template to make changes.

After the initial mockup (which you turn into a template), you just forget
about it and everyone rather works directly on the template. This fixes two
of the issues in the previous approach: There's only a single set of files
*and* you can use your template engine's features to deal with layouts,
partials etc.

The main disadvantage is that you know **need to have the application
running** to see the result; you can no longer open the files in your
browser. Depending on the complexity of your application and the
qualifications of your team, this may or may not be an issue for you. If all
your web designers know how to code, there's not really a problem here. If
you have a very simple application, you can probably teach most people how to
run it. If you on the other hand have a quite complex application with many
moving parts, you'll need to do a lot of work to make it easily runnable for
everyone.

## Mockup-Driven Development

The concept behind Mockup-Driven Development is essentially to combine the
concept of a mockup and a template. The optimal workflow in MDD goes
something like this:

1. Designer cooks up static HTML mockup.
2. Programmer annotates the mockup so the template engine understands it.
3. Designer can still make changes to the mockup and view it in the browser.

MDD boils down to **three essential features**:

* The template must be a static file which can be viewed in a browser.
* The template must also be renderable by the template engine.
* The template should be easy to maintain (e.g. no duplication).

Let's have a look at two template engines that's built upon MDD to easier
understand what we're *really* talking about.

## Implementations
### Lilu and Effigy

Lilu (written by [Yurii Rashkovskii][yrashk]) was the first mockup-based
template engine I discovered. It's not being actively developed anymore, but
luckily there's [Effigy][effigy], another project which is essentially a more
modern version of Lilu. The concept behind them is the same.

You start off with a plain HTML mockup:

    <html>
      <head>
        <title></title>
      </head>
      <body>
        <h1>Post Title</h1>
        <p class="body">Content of the blog</p>
        <div class="comment">
          <h2>Comment Title</h2>
          <p>Content of the comment</p>
          <a>View more</a>
        </div>
        <p id="no-comments">There aren't any comments for this post.</p>
      </body>
    </html>
{: lang=html }

Then you write some glue code in Ruby:

    class PostView < Effigy::View
      attr_reader :post

      def initialize(post)
        @post = post
      end

      def transform
        text('h1', post.title)
        text('title', "#{post.title} - Site title")
        text('p.body', post.body)
        replace_each('.comment', post.comments) do |comment|
          text('h2', comment.title)
          text('p', comment.summary)
          attr('a', :href => url_for(comment))
        end
        remove('#no-comments') if post.comments.empty?
      end
    end
{: lang=ruby }

This approach makes your templates very designer friendly (there's no "weird
stuff"), at the expense of a more loosely connection between the template and
the data. There's nothing in the template which tells the web designer what
is dynamic data, so he might break the page if he for instance changes the
comment titles to use H3 tags instead.

### RuHL

[RuHL][ruhl] is "an opinionated attribute language" written by [Andrew
Stone][stonean]. By placing the dynamic parts into a `data-ruhl` attribute
(as shown below), we have made it explicit which parts are dynamic. As long
as the web designer preserves these annotations, he can freely move
everything around without breaking the page:

    <html>
      <head>
        <title data-ruhl="title"></title>
      </head>
      <body>
        <h1 data-ruhl="title">Post Title</h1>
        <p class="body" data-ruhl="body">Content of the blog</p>
        <div class="comment" data-ruhl="_use: comments">
          <h2 data-ruhl="title">Comment Title</h2>
          <p data-ruhl="comment">Content of the comment</p>
          <a>View more</a>
        </div>
        <p id="no-comments" data-ruhl="_unless: comments">There aren't any comments for this post.</p>
      </body>
    </html>
{: lang=html }

### A few issues...

Initially, the examples above may seem to follow MDD, but there's a few
issues that makes them less convincing. First of all, **there are no layouts
or partials**. Unless you want to repeat yourself in the templates, you'll
have to handle this in code inside your application.

For instance, in Effigy we might do something like:

    class Layout < Effigy::View
      def initialize(view, template)
        @view = view
        @template = template
      end
      
      def transform
        html('#content', @view.render_html_document(@template))
      end
    end
{: lang=ruby }

And suddenly we've broken one rule of MDD: You should be able view the file
in the browser. If you open a template file which depends on the layout, you
will only see the template and not the layout (no CSS or JavaScript for you,
baby).

Also, if we take another look at the Effigy mockup, we'll notice that
something isn't quite right:

    <html>
      <head>
        <title></title>
      </head>
      <body>
        <h1>Post Title</h1>
        <p class="body">Content of the blog</p>
        <div class="comment">
          <h2>Comment Title</h2>
          <p>Content of the comment</p>
          <a>View more</a>
        </div>
        <p id="no-comments">There aren't any comments for this post.</p>
      </body>
    </html>
{: lang=html }

When the application is running, the actual comments will *never* be
displayed together with the "No comments" message, yet that's exactly what
happens in Effigy and RuHL. In this specific case it might not be so
important, but there's a deeper failure here: **The mockup doesn't actually
present the actual application.** Ouch.

## JavaScript to the rescue!

Let me show you two hypothetical templates:

layout.html:

    <html>
    <head>
      <title></title>
      <script src="mockle.js"></script>
    </head>
    <body>
      <mockle yield="content"></mockle>
    </body>
    </html>
{: lang=html }

post.html:

    <script src="mockle.js">
      { "layout": "layout.html" }
    </script>
    
    <h1>Post Title</h1>
    <p class="body">Content of the blog</p>
    
    <div class="comments" mockle:scenario="comments: Many">
      <h2>Comment Title</h2>
      <p>Content of the comment</p>
      <a>View more</a>
    </div>
    
    <p id="no-comments" mockle:scenario="comments: None">
      There aren't any comments for this post.
    </p>
{: lang=html }

Let me introduce you to *Mockle* (which only exists as a concept at the
moment; there's no code available). The main idea is to exploit the fact that
every browser supports JavaScript. The template engine you invoke from your
application will remove the `<script>`-tags, so Mockle.js won't be loaded in
production. However, in development (when you simply open the file in the
browser) Mockle.js will be loaded and it has the privilege of being able to
inspect the HTML and do whatever it likes.

For instance, if you open up the post.html above, it would figure out that it
should use layout.html as the layout. Then it could simply fetch the layout
using Ajax and wrap it around the template. Boom, dead simple layouts and
partials.

To fix the other issue I mentioned above, you could introduce what I call
*scenarios*. By annotating elements as scenarios, Mockle.js could give you a
simple UI (floating panel perhaps?) which allows you to enable/disable each
choice of the scenario.

I'm also using a quite cool trick: When you supply both a URL and some
content to a `<script>`-tag, the content will simply be ignored. However, you
can still easily retrieve the content (both from JavaScript and from any HTML
parser). This gives you a convenient place to store metadata for the
template.

Maybe the scenario idea isn't the best solution. Maybe you want to annotate
it more like RuHL and less like Effigy. Mockle provides no clear solutions,
just a simple idea: **Take advantage of JavaScript to achieve proper
Mockup-Driven Development.**

Maybe I'll start hacking on a specific implementation of Mockle. Maybe not.
What about you? I'd love to [hear](/comments) how this could solve *your*
specific problem.

[dhh-workflow]: http://www.loudthinking.com/arc/000405.html
[yrashk]: https://twitter.com/yrashk
[effigy]: https://github.com/jferris/effigy
[ruhl]: http://docs.stonean.com/page/ruhl
[stonean]: http://stonean.com/
