require 'rouge'
require 'maruku'

module MaRuKu::Out::HTML
  def to_html_code; 
  	source = self.raw_code
  	lang = self.attributes[:lang] || @doc.attributes[:code_lang] 

  	use_syntax = get_setting :html_use_syntax
	
  	element = 
  	if lang
  		begin
  			# eliminate trailing newlines otherwise Syntax crashes
  			source = source.gsub(/\n*\Z/,'')
			
        html = Rouge.highlight(source, lang, 'html')
  			html = html.gsub(/\&apos;/,'&#39;') # IE bug
  			html = html.gsub(/'/,'&#39;') # IE bug
			
  			div = HTMLElement.new 'div'
  			div << html
  			div
  		rescue Object => e
  			maruku_error"Error while using the syntax library for code:\n#{source.inspect}"+
  			 "Lang is #{lang} object is: \n"+
  			  self.inspect + 
  			"\nException: #{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
			
  			tell_user("Using normal PRE because the syntax library did not work.")
  			to_html_code_using_pre(source)
  		end
  	else
  		to_html_code_using_pre(source)
  	end
	
  	add_ws element
  end
end
