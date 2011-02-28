Title: Haters gonna HATEOAS
Subtitle: Some details about REST
Author: steveklabnik

Every time someone mentions RESTful web services, there's always that one person that has to chime in: "That's not _really_ RESTful, it's just kinda RESTful." I'd always filed that information away, under 'things to learn later,' and let it simmer in the back of my brain. I've finally looked into it, and they're absolutely right: 99.99% of the RESTful APIs out there aren't fully compliant with Roy Fielding's conception of REST. Is that bad?

(snip)

Before we answer that question, let's back up a bit: Why aren't these web services RESTful? Just what is REST, anyway? REST was created by Roy Fielding in [his dissertation](http://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm) if you'd like the full lowdown, but we're more concerned with RESTful API design than we are in the full system. A more useful framework for this discussion is the [Richardson Maturity Model](http://martinfowler.com/articles/richardsonMaturityModel.html). Basically, it defines four possible levels of 'REST support':

0. "The Swamp of POX." You're using HTTP to make RPC calls. HTTP is only really used as a tunnel.
1. Resources. Rather than making every call to a service endpoint, you have multiple endpoints that are used to represent resources, and you're talking to them. This is the very beginnings of supporting REST.
2. HTTP Verbs. This is the level that something like Rails gives you out of the box: You interact with these Resources using HTTP verbs, rather than always using POST.
3. Hypermedia Controls. HATEOAS. You're 100% REST compliant.

## The four levels of REST

Let's start at the bottom and work our way up.

Now, The Swamp of POX means that you're using HTTP. Technically, REST services can be provided over any application layer protocol as long as they conform to certain properties. In practice, basically everyone uses HTTP. And since we're discussing the creation of an API that conforms to REST rather than a system architecture based on the principles of REST, HTTP is a solid assumption on our part.

Level one is where it starts to get interesting. REST's 'resources' are the core pieces of data that your application acts on. These will often correspond to the Models in your application, if you're following MVC. A blog, for example, would have Entry resources and Comment resources. API design at Level 1 is all about using different URLs to interact with the different resources in your application. To make a new Entry, you'd use `/entries/make_new`, but with comments, it'd be `/comments/make_new`. So far, so good. This stuff is easy. 

However, there are a set of common operations that are performed on resources, and it seems kinda silly to make a new URI for every operation, especially when they're shared. That's where Level 2 comes in. We're always going to need to perform CRUD operations on our resources, so why not find a way to share these operations across resources? We accomplish this using HTTP Verbs. If we want to get a list of Entries, we make a GET request to `/entries`, but if we want to create a new Entry, we `POST` rather than GET. Pretty simple.

The final level, Hypermedia Controls, is the one that everyone falls down on. There's two parts to this: content negotiation and HATEOAS. Content negotiation is focused on different representations of a particular resource, and HATEOAS is about the discoverability of actions on a resource.

## Content Negotiation
At its simplest, this is something that Rails does right, too. Check out these lines from running `rails scaffold`:

    def index
      @entries = Entry.all
      respond_to do |format|
        format.html
        format.xml { render :xml => @entries }
        format.json { render :json => @entries }
      end
    end
{: lang=ruby }

This is content negotiation. You're able to use MIME types to request a representation of a resource in different formats. Rails 3 has made this even better, with `respond_to`/`respond_with`:

    class EntriesController < ApplicationController::Base

      respond_to :html, :xml, :json

      def index
        respond_with(@entries = Entry.all)
      end
{: lang=ruby }

Super simple. So why do I say people get this wrong? Well, this is a great usage of content negotiation, but there's also one that almost everyone gets wrong. Content negotiation is the answer to the question, "How do I version my API?" The proper way to do this is with the `Accepts` header, and use a MIME type like `application/yourcompany.v1+json`. There's a great article about this by Peter Williams [here](http://barelyenough.org/blog/2008/05/versioning-rest-web-services/).

## HATEOAS

The last constraint is incredibly simple, but nobody actually does it. It's named Hypertext As The Engine Of Application State. I still haven't decided how to pronounce the acronym, I always try to say "Hate ee ohs," which sounds like a breakfast cereal. Anyway, let's break this down. We're using Hypertext, fine, that makes sense. But what's it mean to be an engine? And application state?

It's all about state transitions. It's right there in the name: Representational State Transfer. Your application is just a big state machine.

![fsm](http://i.imgur.com/9E28g.gif)

Your APIs should do this. There should be a single endpoint for the resource, and all of the other actions you'd need to undertake should be able to be discovered by inspecting that resource. Here's an example of what our `Entry` XML might look like if Rails handled HATEOAS:

    <entry>
      <id>1337</id>
      <author>Steve Klabnik</author>
      <link rel = "/linkrels/entry/newcomment"
            uri = "/entries/1337/comments" />
      <link rel = "self"
            uri = "/entries/1337" />
    </entry>

When we GET a particular Entry, we discover where we can go next: we can make a new comment. It's a discoverable action. The particular state we're in shows what other states we can reach from here.

Now, when I said 'nobody' does this, what I meant was 'for APIs.' This is exactly how the Web works. Think about it. You start off on the homepage. That's the only URL you have to know. From there, a bunch of links point you towards each state that you can reach from there. People would consider it ludicrous if they had to remember a dozen URLs to navigate a website, so why do we expect the consumers of our APIs to do so as well?

There's another benefit here as well: we've decoupled the URL itself from the action we're having it perform. Think about it like the web: If we have a link that says "click here to make a new blog entry" and next week, we change it from `/entries/new` to `/somethingelse/whatever`, users of the web site (probably) won't notice: they're just clicking on the link that takes them where they need to go. If you changed the text to "click here to do something else" they wouldn't expect it to be making an Entry anymore. By the same token, we can change the URI in our `<link>` tag, and a proper client will just automatically follow along. Brilliant!

## Why aren't we doing this already?

Well, for one thing, the tooling just isn't there to do this. Think of how web development was before Rails started emphasizing REST: some people got it right, but not many people cared. I know that I had teachers telling me that a `<form>` with `method="GET"` was perfectly fine, and that the only real difference between `GET` and `POST` is if the parameters are in the URL... but I digress. Until we make this kind of development easy to do, people aren't going to do it. There's also a serious lack of education on this topic. The web development community has been steadily improving as the web grows and matures, and so I hope that eventually we'll see more people actually adopting HATEOAS and going 'full RESTful.'

There's also some discussion about how useful extra constraints actually are. If this is such a big important deal, why aren't more people doing it? I haven't yet implemented a 100% RESTful API myself yet, so I can't really say. I do believe that I'll be giving it a shot in the future, and I think that as our collective understanding of Fielding's work improves, we'll eventually see the value in REST.
