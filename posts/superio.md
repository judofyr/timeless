Title: SuperIO
Subtitle: Convert everything to an IO
Author: judofyr

    require 'open-uri'
    require 'stringio'

    # == Feed me with:
    # 
    # Filename::   and I'll give you the file!
    # URL::        and I'll give you the content!
    # Any string:: and I'll give you a StringIO!
    # An integer:: and I'll give you the stream for
    #              the given integer file descriptor! 
    # Any IO::     and I'll give you the same IO!
    #
    # == Set +type+ to:
    #
    # +:auto+::    and I'll figure it all out for you!
    # +String+::   and you'll get a nice StringIO, no matter what!
    # 
    def SuperIO(io, type = :auto)
      return StringIO.new(io) if type == String
      raise "Unknown type" unless type == :auto
      case io
      when IO
        io
      when Integer
        IO.new(io)
      when String
        if File.exists?(io)
          File.new(io)
        elsif ((uri = URI.parse(io)).respond_to?(:open) rescue false)
          uri.open
        else
          StringIO.new(io)
        end
      else
        raise "Cannot convert to IO"
      end
    end 
{: lang=ruby }
