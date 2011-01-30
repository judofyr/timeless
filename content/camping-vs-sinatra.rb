#!/usr/bin/ruby
SIX (UNIMPRESSIVE)                 # Markdown version:
REASONS CAMPING IS BETTER          # 1) ruby camping-vs-sinatra.rb
THAN YOU WOULD IMAGINE

reasons.push(COMMUNITY) do %%
  Yes, Sinatra has a big community, but Camping definitely has a great
  community too. Size doesn't always matter. Because there are so few users,
  it means every single issue gets full attention.

  If you're only looking at the GitHub repo or ruby.reddit.com, Camping
  might seem a little dead, but that's because everything happens on the
  mailing lists so it's not always visible from the "outside". (And other
  times, we're simply restin', just waiting for a question, suggestion or
  comment.)

  Besides, I don't allow Camping to disappear. Not because I need it in my
  business or something like that, but because the code is so fucking great.
  I simply won't allow it to die. Therefore I will *always* do my best to
  help people who are camping (just ask Eric Mill on this mailing list).
%%%%% end

reasons.push(UNPOLLUTED) do %%
  In Sinatra it's a norm (whether you use Sinatra::Base or not), in Camping
  it's the law:

      Camping.goes :Blog
      module Blog; end

      Camping.goes :Wiki
      module Wiki; end

  Every application lives under its own namespace. Yes, it requires a few
  more characters, but when you think about it, why *should* we allow are
  apps to run directly under the global namespace? That's surely not how we
  design our other Ruby code. What makes it so different? Shouldn't you for
  instance be able to `require "app"` and `include App::Helpers` somewhere
  else?

  Think of the environment; reduce your pollution!
%%%%% end

reasons.push(RESTful) do %%
  A central idea in REST is the concept of a resource, and that you can call
  methods on the resource (in order to get a representation of it). How would
  you apply these ideas in Ruby? What about this?

      class Posts
        def get; end
        def post; end
      end

  I would say this fits the description perfectly. You can instantiate
  instances of this class (with different parameters etc.) for each request,
  and then call methods on it. Guess how it looks in Camping?

      module App::Controllers
        class Posts
          def get; end
          def post; end
        end
      end

  The best part: Camping doesn't care if you use GET, DELETE, PROPFIND or
  HELLOWORD; every method is threated equally. One of the early ideas of HTTP
  was that you could easily extend it with your own methods for your own
  needs, and Camping is a perfect match for these cases!
%%%%% end

reasons.push(RUBY) do %%
  Ruby has wonderful features such as classes, inheritance, modules and
  methods. Why should every single DSL replace these features by blocks?
  Often, all they do is to hide details, without improving anything else than
  line count. Let me show you an example:

      get '/posts' do
        # code
      end

  Now answer me:

  1. Where is this code stored?
  2. How do I override the code?
  3. What happens if I call `get '/posts'` again?

  Not quite sure? Let's have a look at Camping:

      module App::Controllers
        class Posts
          def get
            # code
          end
        end
      end

  Since this is just "plain" Ruby, it's much simpler:

  ### 1. Where is this code stored?

  The code is stored as a method, and we can easily play with it:

      Posts.instance_methods(false) # => [:get]
      Posts.instance_method(:get)   # => #<UnboundMethod: Posts#get>
      # Given post.is_a?(Posts)
      post.methods(false)           # => [:get]
      post.method(:get)             # => #<Method: Posts#get>

  ### 2. How do I override the code?

  Just like you would override a method:

      class App::Controllers::Posts
        def get
          # override
        end
      end

      # or, if post.is_a?(Posts)

      def post.get
        # override
      end

  ### 3. What happens if I call `class Posts` again?

  Because Ruby has open classes, we know that it would have no effect at all.

  ------------

  Another advantage of having resources as classes (and not as blocks):

      module IUseTheseMethodsALot
        def get; end
      end

      module App::Controllers
        class Posts
          include IUseTheseMethodsALot
        end

        class Users
          include IUseTheseMethodsALot
        end
      end
%%%%% end

reasons.push(NAMING) do %q%
  In Camping you'll have to give every resource a name, while in Sinatra
  they're always anonymous. By giving resources a name you have a way of
  referencing them, which can be very convenient:

      post '/issue' do
        issue = Issue.create(params[:issue])
        redirect "/issue/#{issue.id}/overview"
      end

  Since every resource is anonymous in Sinatra, you're forced to hard-code
  the path. Not very elegant, and it can be a pain to update the code if you
  for instance want to move all urls from issue/ to i/. Camping's solution:

      class Issue
        def post
          issue = Issue.create(@input.issue)
          redirect R(IssueOverview, issue)
        end
      end

  The R method in Ruby returns the URL to a resource (which takes one
  parameter). Camping automatically calls #to_param on the arguments, so you
  can safely pass in ActiveRecord objects too. If you want to change the
  route to IssueOverview, you can do this in *one* place and you're done.
%%%%% end

reasons.push(RELOADING) do %%
      $ camping app.rb
      ** Starting Mongrel on 0.0.0.0:3301

  The Camping Server provides code reloading (so you don't need to restart
  the server while you develop your app) that works out of the box on *all*
  platforms (including Windows). We actually care about our Windows users!
%%%%% end
                                                                        ''
                                                                        ''
BEGIN {def Object.const_missing(m);m.to_s end;def method_missing(*a)a[1]=
$h.pop if a[1]==$h;$h.push(a) end;$h = [];def reasons; $reas ||= {};end;''
def reasons.push(r,&b);self[r]=b.call;end;END {puts h=$h*' ','='*h.size,''
reasons.each { |name, val| puts name, '-'*name.size, val.gsub(/^  /,''),''
                                                                        ''
}}}  # Please keep all my mustaches intact.   // Magnus Holm