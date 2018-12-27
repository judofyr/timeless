Title: When in Doubt, Turn to _why
Author: judofyr

For a long time, [Rack couldn't parse nested hash params][nested-fail].
That's  was pretty annoying, so until they decided how to implement it in
the best way, every other framework were cleaning up after Rack. My
[attempt][camping-fail] to do it in Camping is clearly a bad solution, so I
decided to have a look at other implementations and steal some ideas.

## Let's use Sinatra as an example

Most of them are were similar to Sinatra's (this is slightly modified for
readability, but the idea still applies):

    params.inject({}) do |hash, (key, value)|
      if key =~ /\[.*\]/
        parts = key.scan(/(^[^\[]+)|\[([^\]]+)\]/).flatten.compact
        head, last = parts[0..-2], parts[-1]
        head.inject(hash){ |s,v| s[v] ||= {} }[last] = value
      else
        hash[key] = value
      end
      res
    end   
{: lang=ruby }

This implementation was taken from an example posted to the Rack ML by 
Michael Fellinger (of Ramaze fame). For the background on the patch that
went into Sinatra: take a look [the ticket][sinatra-ticket] over at their
bug tracker.

We're looping through each of the params and checks if the key includes
brackets. If so, the param is nested and it starts by finding the different
parts:

    parts = key.scan(/(^[^\[]+)|\[([^\]]+)\]/).flatten.compact
{: lang=ruby }

The first part of the regex matches from the beginning of the key to the first
\[, while the second matches each of the \[parts\]. Some cleanup is needed to
flatten and remove nils (just try the line in IRB and you'll see it quickly).

Next up, we're splitting out the last part, before we use inject to build up a
Hash:

    head.inject(hash){ |s,v| s[v] ||= {} }[last] = value  
{: lang=ruby }

Here, we're building a Hash based on the params we've already cleaned up
and the current param we're working on. Then, finally, we're setting the
value.

## The \_why way

All of this makes sense. I wrote approximately the same when trying to
cleanup my broken version. However, while I was looking for the way Ramaze
did it, I found an excellent link to RedHanded: [Injecting a Hash Backwards
and the Merge Block][why-win]. That version is just *awesome* (this is also
slightly modified):

    m = proc {|_,o,n|o.merge(n,&m)}
    params.inject({}) do |hash, (key, value)|
      parts = key.split(/[\]\[]+/)
      hash.merge(parts.reverse.inject(value) { |x, i| {i => x} }, &m) 
    end    
{: lang=ruby }

Notice the sweet, micro way to split out the parts: If we got a key like:
"first\[second\]\[third\]" we can simply split by any numbers of \[ and \]
and we'll end up with "first", "second" and "third". Of course, this is
going to fail on stuff like "this\]is\]really\]one\]key", but we can safely
assume that nobody uses such parameter names.


Now, the next is what makes this so different and awesome. Let's look at
first part of it:

    parts.reverse.inject(value) { |x, i| {i => x} }
{: lang=ruby }

We're *reversing* it and building it backwards. The inject starts with our
original value and then we build our way out by creating Hashes:

    parts = ["first", "second", "third"]
    value = 123

    # first run of inject:
    x = 123
    i = "third"
    return { "third" => 123 }

    # second run of inject:
    x = { "third" => 123 }
    i = "second"
    return { "second" => { "third" => 123 } }

    # second run of inject:
    x = { "second" => { "third" => 123 } }
    i = "first"
    return { "first" => { "second" => { "third" => 123 } } }
{: lang=ruby }

So when we got this little recursive Hash, we need to merge it with the
rest. Most of you, including me, would say that it would be a hard task,
since we also need to merge it recursively:

    params = { "first" => { "second" => { "third" => 123 } } }
    current_param = { "first" => { "another" => 456 } }

    params.merge(current_param) # fail!
    current_param.merge(params) # fail!
{: lang=ruby }

## Meet the Merge Block

This was the first time I've ever _heard_ of the merge block. It's not even
properly documented! But it's a very simple and very powerful feature: If
we get a merge conflict (same keys in both Hashes), it's calling that
block.

    params = { "first" => { "second" => { "third" => 123 } } }
    current_param = { "first" => { "another" => 456 } }

    params.merge(current_param) do |key, value_from_params, value_from_current_param|
      # key is defined in both params and current_param.
      # In this case we can simply merge them again.
      value_from_params.merge(value_from_current_param)
    end

    # =>
    { "first" => { "second" => { "third" => 123 }, "another" => 456 } }
{: lang=ruby }

And in order to merge it recursively, we build the block in advance and
pass the block into the inner merge too:

    m = proc {|_,o,n|o.merge(n,&m)}
    # ...
    hash.merge(recursive_hash, &m) 
{: lang=ruby }

## Shorter? Faster?

I believe the first, natural way (which is used in Rack today) is both
faster and shorter, but guess which version I added to Camping? As a
wise man once said:

> Not all code needs to be a factory, some of it can just be origami.

Let's leave the factories to Java, shall we?

[nested-fail]: http://groups.google.com/group/rack-devel/browse_thread/thread/1a9b8dc431bff499
[camping-fail]: http://github.com/camping/camping/commit/95d2262c#L0R416
[why-win]: http://redhanded.hobix.com/inspect/injectingAHashBackwardsAndTheMergeBlock.html
[sinatra-ticket]: http://sinatra.lighthouseapp.com/projects/9779/tickets/70
[origami]: http://www.mail-archive.com/camping-list@rubyforge.org/msg00548.html

