# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.
include Nanoc3::Helpers::LinkTo

module LinkHelper
  def html_to(text, url, attribs = {})
    link_to(text.gsub(/_/, " "), url, attribs)
  end

  def markdown_to(text, url, attribs = {})
     "[#{text}](#{url})"
  end

  def auto_to(text, url, attribs = {})
    if @item and @item[:extension] and @item[:extension].end_with? "md"
      markdown_to(text, url, attribs)
    else
      html_to(text, url, attribs)
    end
  end
end

include LinkHelper
