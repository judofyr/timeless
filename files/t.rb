def meta_def(m,&b)
  extend(Module.new{define_method(m,&b)})
end

Road = Struct.new(:a, :b) do
  def to_s
    "a #{a} and #{b} road"
  end
  
  def middle
    "the middle...\nof the road"
  end
end

Demon = Struct.new(:a) do  
  def shined!(opts)
    puts "there shined a #{a} demon..."
    puts "in #{opts[:in]}."
    puts
  end
  
  def said(s)
    puts "And he said:"
    puts "\"#{s}\""
    puts
  end
  
  def ==(a)
    puts "the beast was stunned.\nWhip-crack went his whippet tail," if a == :stunned!
    puts "And the beast was done." if a == :done!
  end
  
  def asked(person, s)
    puts "He asked us:"
    puts "\"#{s}\""
  end
end

Person = Struct.new(:name) do
  def eyes
    "my eyes"
  end
  
  def believe!(who)
    puts "#{name.capitalize} gotta believe #{who}!"
    puts "And I wish you were there!"
    puts "Just a matter of opinion."
  end
  
  def to_s
    name
  end
end

People = Struct.new(:a, :b) do
  def looked(opts)
    puts "Well #{a} and #{b},... we looked at #{opts[:at]},"
  end
  
  def said(s)
    meta_def(:said) do |s|
      puts "And we said,"
      puts "\"#{s}\""
    end
    puts "and we each said..."
    puts "\"#{s}\""
    puts
  end
  
  def hitchhiked!(road)
    puts "we was hitchhikin' down #{road}."
  end
  
  def played(s)
    song = yield
    puts "And we played #{s},"
    puts "Just so happened to be,"
    puts "#{song},"
    puts "it was #{song}."
    puts
  end
  
  def remember(s)
    puts "Couldn't remember #{s}, No."
    puts "No!"
  end
end

class Symbol
  def ago(s)
    if self == :long
      puts "Long time ago #{s}"
      yield
    end
  end
end

class Fixnum
  def +(o)
    if o == 1
      puts "One and one make two," if self == 1
      puts "Two and one make three,\nIt was destiny.\n\n" if self == 2
    end
  end
  
  def years
    self
  end
end

class S
  def initialize(obj)
    @obj = obj
  end
  
  def doth(a)
    case @obj
    when :sun
      print "When the sun doth #{a} "
    when :moon
      puts "and the moon doth #{a}"
    when :grass
      puts "and the grass doth #{a} ooh"
      puts
    end
    true
  end
end

class Song  
  def initialize(name, &blk)
    @name = name
    @beast = @demon = Demon.new(:shiny)
    @me = @my = Person.new('me')
    @kyle = Person.new('Kyle')
    @you = Person.new('you')
    @we = @us = People.new(@me, @kyle)
    @sun = S.new(:sun)
    @moon = S.new(:moon)
    @grass = S.new(:grass)
    
    instance_eval(&blk)
  end
  
  def tribute!
    puts "This is the greatest and best song in the world's."
    puts "Tribute..."
    puts
  end
  
  def tribute(opts)
    puts "This is a tribute, oh,"
    puts "To #{opts[:to]},"
    puts "All right!"
    puts "It was #{opts[:to]},"
    puts "All right!"
    puts "And it was the best mother fuckin' song,"
    puts "#{opts[:to]}!"
    puts
    puts "Allllllright!"
    puts "Ti Tuga digga tu Gi Friba fligugibu Uh Fligugigbu Uh Di Ei Friba Du Gi Fligu fligugigugi Flilibili Ah"
    puts "(Bow) (Bow) (Bow) (Ooh) (Bow) (Bi)"
    puts "Fligu wene mamamana Lucifer!"
    puts "(Mene) (LUCIFER)!"
    puts
  end
  
  def suddenly!
    puts "All of a sudden,"
  end
  
  def look(opts)
    puts "Look into #{opts[:into]} and it's easy to see"
  end
  
  def every(a)
    puts "Once every hundred-thousand years or so,"
    yield
  end
  
  def need(opts)
    puts "Needless to #{opts[:to]},"
    yield
  end
  
  def rock!
    puts "Rock!!"
    puts "Ahhh, ahhh, ahhh-ah-ah-ah-ah-ahn,"
    puts "Ohhh, whoah, ah-whoah-oh!"
    puts
  end
  
  def ==(o)
    puts "This is not #{o}, No." 
  end
  
  def just(s)
    puts "This is just a #{s}."
  end
  
  def peculiar(a)
    puts "And the peculiar #{a} is this my friends:"
    puts yield.gsub(/^ +/,'').strip
    puts
  end
  
  def fuck!
    puts %q{Ah, fuck!
Good God, God lovin' ,
So surprised to find you can't stop me, now.
I'm on fire--
O hallelujah I'm found! Rich motherfucker compadre (oooh)!
All right!
All right!}
  end
end