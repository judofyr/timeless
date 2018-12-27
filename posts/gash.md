Title: Gash
Subtitle: Access a Git repo as a Hash
Author: judofyr


    sudo gem install gash

* Gash lets you access a Git-repo as a Hash.
* Gash doesn't touch your working directory
* Gash only cares about the data, not the commits.
* Gash only cares about the _latest_ data.
* Gash can commit.
* Gash will automatically create branches if they don't exist.
* Gash only loads what it needs, so it handles large repos well.
* Gash got [pretty good documentation][gash-docs].
* Gash got [a bug tracker][gash-lh].
* Gash is being [developed at GitHub][gash-github].

## Let me show you what I mean...

    require 'gash'
    wiki = Gash.new("~/programming/sources/gash/.git", "wiki")

    # See, it doesn't exists yet!
    wiki.branch_exists? # => false

    # Lets add some files...
    wiki["Start"] = "Welcome to this great [[Wiki]]!"
    wiki["Wiki"] = "Something everyone can edit."

    # And commit them.
    wiki.commit("First version")

    # Now it exists!
    wiki.branch_exists? # => true

    # We can use all the regular Hash-methods too:
    wiki.merge!("Start" => "Se our new section: [[Git]]",
                "Git/About" => "An awesome SCM.")

    wiki["GitSCM"] = wiki.delete("Git")

    wiki.commit("Adding a Git-section")

    # And some special methods:
    wiki["Git"].tree?                         # => true
    wiki["Git/About"] == wiki["Git"]["About"] # => true
    wiki["Git/About"].blob?                   # => true
    wiki["Git/About"].sha1                    # => "123456789"
    wiki["Git/About"].mode                    # => "100644"
{: lang=ruby }

[gash-docs]: http://dojo.rubyforge.org/gash
[gash-github]: http://github.com/judofyr/gash
[gash-lh]: http://dojo.lighthouseapp.com/projects/17529-gash

