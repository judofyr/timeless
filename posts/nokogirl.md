Title: Nokogirl
Subtitle: Because programmers can't splell
Author: judofyr

Every time I play with [Nokogiri][nokogiri], I get this weird error:

    $ irb -rnokogirl
    no such file to load -- nokogirl (LoadError)

My head just can't accept it's called *nokogiri* instead of *nokogirl*. Hopefully, this should teach me:

    $ sudo gem install nokogirl
    Building native extensions.  This could take a while...

    ********************************************
    It's actually spelled nokogiri, not nokogirl
    ********************************************

    Successfully installed nokogiri-1.2.1
    Successfully installed nokogirl-1.0
    2 gems installed

    $ irb -rnokogirl

    ********************************************
    It's actually spelled nokogiri, not nokogirl
    ********************************************

    >> Nokogirl
    => Nokogiri

[nokogiri]: http://nokogiri.org/

