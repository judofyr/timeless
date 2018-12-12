Title: Copy Paste
Subtitle: Access the clipboard in IRB
Author: judofyr
HTML use syntax: true

Stick this in your .irbrc:

    # Evaluate the code on the clipboard.
    def ep
      IRB.CurrentContext.workspace.evaluate(self, paste)
    end

{: lang=ruby }

And then add one of these:

Mac
---

    def copy(str)
      IO.popen('pbcopy', 'w') { |f| f << str.to_s }
    end
    
    def paste
      `pbpaste`
    end

{: lang=ruby }

Linux
-----
    
    # http://gist.github.com/124272
    # Thanks to Bjørn Arild Mæland
    def copy(str)
      IO.popen('xclip -i', 'w') { |f| f << str.to_s }
    end
    
    def paste
      `xclip -o`
    end
{: lang=ruby }
