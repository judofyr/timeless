# *Literate programming* is a method of crafting software that Don Knuth described in 1984 in his paper [Literate Programming](http://www.literateprogramming.com/knuthweb.pdf). A literate program places emphasis on the way that people understand the problem a particular piece of software is attempting to solve, rather than the way that computers interpret the source code.
#
# This is an example of literate programming using [Rocco](https://github.com/rtomayko/rocco). This `literate-programming.html` file is the output of running `rocco content/literate-programming.rb` from the root directory of the [Timeless source code](https://github.com/judofyr/timeless). You can also view [literate-programming.rb](/literate-programming.rb) directly.
#
# If you've been linked here from somewhere external, this article is part of
# [Timeless](http://timeless.judofyr.net). Since this page was generated with
# a different tool, it looks differently than the rest of the site. Please
# forgive my small navigational error, as I think that writing a post in a tool
# it's describing is interesting enough to create a small crisis of navigation.

### Some Setup

# This particular source code file is a `Rakefile`, meaning that it can be run
# using the the `-f` switch to `Rake`: 
#
#     rake -f content/literate-programming.rb
#
# This will run the *default* task, which will run `rocco` on the Ruby file and
# output the proper HTML.

require 'rubygems'
require 'rake'

desc "Generate documentation"
task :default do
  sh "rocco content/literate-programming.rb"
end

# We're also going to allow running this file with a regular `ruby
# content/literate-programming.rb`, so in order to facilitate this, I'm going
# to write a `method_missing` that simply catches all unnamed methods and
# returns `true`. If you're not a Rubyist, then don't worry about this too much;
# basically it's what lets my illustrations later work without causing
# a software error. This would normally be bad programming practice, but this
# is an illustrative, experimental file. You'd never encounter this in a 'real'
# program.

def method_missing(sym, *args, &block)
  true
end

# I also need to do this with `gets`, or else the program will hang, waiting
# for input.
def $stdin.gets
  nil
end

### How it's done now

# Of course, I know that you'd never write software in this way, but maybe you
# have a friend? I've heard that lots of people out there write code like this:

namespace :build do

##### Steps to create software.

# * Sit down at the computer, and bang out a bunch of code.
# * Then, we open our creation, and try it out. If it has some bugs, fix them
# over and over until we're pretty sure they're gone.
# * At this point, we should be bug free. Let's cross our fingers! We probably
# should write a few comments in our code, and then let's send it off to users!

  task :poor do
    write_code
    try_program

    until it_works?
      fix_bugs
    end
    write_some_comments
    ship_it
  end

# Now, the problem comes when we find more bugs later in the program's
# lifetime. If it's been a while since you've last seen this code, you're 
# going to need some help getting up to speed. Hopefully you did a good job in 
# `write_some_comments`!

### We can do better than this!

# I'm sure that at your shop, it looks a little bit different. You care about
# documentation, because you know that when you have to look at your code
# later, or when you have to bring a new member on board, you have an education
# problem. The knowledge was either forgotten or was never there in the first
# place, and now you've gotta have it. So what do you do? Documentation. That
# way, when that new hire is learning her way around the codebase, she can just
# read your documentation!

  task :better do
    write_code
    write_documentation

    try_program

    until it_works?
      fix_bugs
    end

    ship_it
  end

# This is pretty good, but it's still not as good as we can do. There's two
# problems with this approach: 
#
# * You're still doing the documentation after the fact.
# * Your documentation is divorced from your code itself.

# Let's delve into each of these.

### Documentation afterward
#
# I initially became a big fan of test-first development methodologies when
# I came to terms with something about myself: As soon as my code 'works,'
# I feel like it's done. I want to ship it out the door. I also feel this way
# about writing; I find editing myself after the fact to be a bit tedious, and
# it's difficult for me to be as hard on myself as I should be. It's already
# written, just post it already!
#
# That's why I'm a big fan of putting off coding to the absolute last part of
# a project. Here's some things I'd rather be doing before writing code:
#
# * Thinking about the problem that I'm going to solve, and different ways of
# solving it.
# * Investigating similar solutions that others have used in the past.
# * Writing automated tests.
# * Writing documentation.

# Yep, that's right. I'm not perfect at this, but lately I've come to the
# conclusion that documentation is important enough that I need to do it
# _first_, otherwise, it'll never get done. Tom Preston-Warner says it better
# than I can in 
# [README driven development](http://tom.preston-werner.com/2010/08/23/readme-driven-development.html). 
#
# > Consider the process of writing the Readme for your project as the true act of creation. This is where all your brilliant ideas should be expressed. This document should stand on its own as a testament to your creativity and expressiveness. The Readme should be the single most important document in your codebase; writing it first is the proper thing to do.
  task :best do
    think_about_problem
    check_for_existing_libraries
    write_documentation
    write_tests
    write_code
  end
#
# While maybe a bit dramatic, Tom's got it right: Documentation is important.
# So do it first.
end


### Documentation and code aren't together
#
# The only thing worse than having no documentation is having documentation
# that's wrong. Or that's only... sort of right.

# Returns the value of π
def pi
  3
end

# Ugh! I mean, this is _sort_ of correct, but probably not what you were
# expecting.
#
# This problem is a subtle one. Nobody sets out to write poor explanations. In
# fact, I bet the first version of the `pi` method probably looked like this:

# Returns the value of π
def pi
  Math::PI
end

# But then, as times change, the `pi` method need to change, too. Now,
# changing the value of `pi` seems really stupid, but maybe your new programmer
# is a junior. Or you're coding while drinking. Or you've just plain had a bad
# day, and aren't thinking straight. Nobody is at the top of their game 100% of
# the time. This is where the danger lies: Your code and your documentation
# gets out of synch. It happens to the best of us.
#
# The easiest way to make sure that your documentation stays up to date is to
# keep it as close as possible to the code that you're changing. If the
# description is staring you in the face, it's harder to ignore.
#
# We have tools to aid you in doing this. Docco is one of them. RDoc or JavaDoc
# are others. They extract the comments that you write and turn them into
# webpages, so that you can share them with others.

### Software as a web of docs and code

# While tools like Docco are fantastic, they're not _real_ literate
# programming. Literate software means more than just "cleverly pull comments
# out of code and turn it into HTML." To truly understand literate programming,
# we need to consider the nature of what combining code and documentation
# actually means. Knuth gives us a clue:
#
# > The main point is that [a literate program] is inherently bilingual, and
# that such a combination of languages proves to be much more powerful than
# either single language by itself. [Literate programming] does not make the
# other languages obsolete; on the contrary, it enhances them.
class LiterateProgram
  attr_accessor :source
  attr_accessor :documentation
end

# This duality is incredibly important in understanding why literate
# programming is actually different from what's been done before; it's an
# observation that gets to the core of what it means to write software. One of
# my favorite quotes on software comes from the preface of the first edition of 
# [The Structure and Interpretation of Computer Programs](http://mitpress.mit.edu/sicp/full-text/book/book.html):
#
# > Programs must be written for people to read, and only incidentally for machines to execute.

# But unfortunately, while human languages are excellent at describing broad
# ideas, they're generally poor at the exact specifics that computers need to
# do their job properly. Programming languages have the opposite problem in
# that they're excellent for computers, but it's difficult for humans to
# discern the larger picture from a body of code. Literate programming aims to
# rectify this impedance mismatch by combining the two into a single body of
# work. Knuth refers to this work as a *web*, and while he claims that he chose
# this name in a quite informal manner, it's an incredibly apt name that has
# subtle implications we'll explore in a moment. From a *web* you can use
# a tool named *weave* to generate a file suitable for generating more
# traditional documentation, and you can use the *tangle* tool to produce
# a body of code suitable for compilation.
def weave(web)
  $stdout.puts format_documentation(web)
end

def tangle(web)
  $stdout.puts format_output_code(web)
end

# Earlier, I mentioned that literate programming is more than simply extracting
# comments. The important thing that Docco is missing are *macros*. Literate
# programming macros are similar to the concept of macros in other languages;
# they are simply a name that's given to a piece of code, such that it can be
# substituted by the preprocessor. The reason macros are important is that
# allows code to be declared out of the order that the computer requires, and
# in the order that the person reading it wants.

# For example, if you were to run this code:

calculate user_input

user_input = $stdin.gets

def calculate x
  x + 2
end

# you would generate an error. You need to define the `calculate` method before
# you used it, and the same with `user_input`. It's all out of order! But maybe
# this way makes the most sense when we're trying to explain the program.
# Macros would allow us to say something like:

# ---------

#     The program will execute these steps in order:
#
#     * <Get input from the user 2>
#     * <Define a calculation function 3>
#     * <Calculate a value from the input 1>

#     The meat of the program is in the calculation on the user input. Since it's
#     the main thing we're trying to do, it's simple: just one line:
#     <1>
#     calculate user_input

# ---------

# And so on. We could then explain each section in the order we want, and our
# *tangle* program will re-arrange them into the order that the computer needs.
# Knuth considered this incredibly important, enough that systems that don't
# have this ability would not actually be called literate systems.

### Code as a web.
#
# At first glance, a simple ordering of code seems to be a quite minor feature.
# However, it represents a deeper structural difference between the way that we
# understand concepts and the way that a computer does; the human mind tends to
# think of things as an interconnected network of concepts, and a computer
# only understands ordered lists of commands. This relationship is one of the
# fundamental leaks in the software abstraction.
#
# > I think that a complex piece of software is, indeed, best regarded as a web that has been delicately pieced together from simple materials. We understand a complicated system by understanding its simple parts, and by understanding the simple relations between those parts and their immediate neighbors. If we express a program as a web of ideas, we can emphasize its structural properties in a natural and satisfying way.
#
# Trading off understanding simply to make it easier for a computer to
# interpret our program makes no sense; man has mastery over machine. It's hard
# enough to create reliable programs without artificial impediments in our way!
# This is a major structural shift, and dramatically increases our ability to
# express what we want a program to do, rather than simply describe how the
# computer understands our source code.

### So is all of this worth it?
#
# Knuth seems to think so:
#
# > Programming is a very personal activity, so I can't be certain that what
# has worked for me will work for everybody. Yet the impact of this new
# approach on my own style has been profound, and my excitement has continued
# unabated for more than two years. I enjoy the new methodology so much that it
# is hard for me to refrain from going back to every program that I've ever
# written and recasting it in "literate" form.
#
# Time will tell. I know that I've been searching for a better way to blend
# documentation and code together, and it seems like tools such as Docco are
# almost there. I've already converted the Hackety Hack website over to Docco,
# and I've enjoyed it a lot. I'm not 100% convinced that it's the best
# solution that exists, but it sounds appealing, and my results have been good
# so far.
#
# If you have significant experience programming in a literate style, I'd love
# to [hear from you](http://timeless.judofyr.net/comments). Also, there is
# a small chance that I'd like to build a macro system on top of Docco, so if
# that interests you, please get in touch and we can talk about it.
