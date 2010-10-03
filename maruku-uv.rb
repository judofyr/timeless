require 'uv'
require 'maruku'

module MaRuKu::Out::HTML
  def to_html_code; 
  	source = self.raw_code
  	lang = self.attributes[:lang] || @doc.attributes[:code_lang] 
  	lang = 'xml' if lang=='html'

  	use_syntax = get_setting :html_use_syntax
	
  	element = 
  	if lang
  		begin
  			# eliminate trailing newlines otherwise Syntax crashes
  			source = source.gsub(/\n*\Z/,'')
			
  			html = Uv.parse(source, "xhtml", lang, false, "idle")
  			html = html.gsub(/\&apos;/,'&#39;') # IE bug
  			html = html.gsub(/'/,'&#39;') # IE bug
			
  			code = Document.new(html, {:respect_whitespace =>:all}).root
  			code.name = 'code'
  			code.attributes['class'] = lang
  			code.attributes['lang'] = lang
			
  			pre = Element.new 'pre'
  			pre << code
  			pre
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
