require 'nokogiri'

class SyntaxHighlight < Nanoc::Filter
  identifier :syntax_highlight
  type :text

  def run(content, params={})
    doc = Nokogiri::HTML(content)

    doc.search("//pre[@class='firehol']").each do |node|
      if node.children.count == 1
        node.inner_html =
          firehol_highlight(node.inner_html).strip
      end
    end

    doc.search("//pre[@class='fireqos']").each do |node|
      if node.children.count == 1
        node.inner_html =
          fireqos_highlight(node.inner_html).strip
      end
    end

    doc.search("//code").each do |node|
      node.inner_html = node.inner_html.strip
    end

    doc.to_html
  end

private
  def firehol_highlight(text)
    fixup_code(text, [ "/firehol/", "/service/" ] )
  end

  def fireqos_highlight(text)
    fixup_code(text, [ "/fireqos/"] )
  end

  def fixup_code(text, prefixes)
    keyword_urls = {}
    @items.select { |item| item.identifier.match(/^\/keyword\//) }.each do |k|
      keyword_urls[k.attributes[:url]] ||= []
      keyword_urls[k.attributes[:url]] << k
    end
    raise "No keyword URLs available" unless keyword_urls.size > 0

    outtext = ""
    lines = text.split("\n").collect do |line|
      # The gsub()s undo pandoc treating the span newcode from included
      # examples as literal text
      line.gsub!(/&lt;span class="newcode"&gt;/, '<span class="newcode">')
      line.gsub!(/&lt;\/span&gt;/, '</span>')

      first_word = true
      ss = StringScanner.new(line)
      loop do
        is_word = false
        word = if ss.peek(1) == "<"
                 ss.scan(/<[^>]*>/)
               elsif ss.peek(1) == "#"
                 w = ss.scan(/.*/)
                 '<span class="comment">' + w + '</span>'
               elsif ss.peek(1) == "$"
                 w = ss.scan(/\$\{?[A-Za-z0-9_]+\}?/)
                 '<span class="var">' + w + '</span>'
               elsif ss.match?(/\s+/)
                 ss.scan(/\s+/)
               elsif ss.match?(/\w+=/)
                 w = ss.scan(/\w+/)
                 ss.getch
                 '<span class="var">' + w + '</span>='
               elsif ss.match?(/[\w&+-.]+/)
                 is_word = true
                 ss.scan(/[\w&+-.]+/)
               else
                 ss.getch
               end

        break if word.nil?

        word = replace_word(word, first_word, line, prefixes, keyword_urls)
        outtext += word
        first_word = false if is_word
      end
      outtext += "\n"
    end
    outtext
  end

  def replace_word(word, is_first, whole_line, prefixes, keyword_urls)
    match = nil

    prefixes.each do |prefix|
      keywords = keyword_urls[prefix + word]
      keywords ||= []
      default_match = nil

      keywords.each do |keyword|
        if keyword.attributes[:match] == nil or keyword.attributes[:match] == :default
          default_match = keyword
        elsif keyword.attributes[:match] == :none
          # do not try to match these, manual references only
        elsif keyword.attributes[:match] == :is_first
          match = keyword if is_first
        elsif keyword.attributes[:match] == :not_first
          match = keyword if not is_first
        elsif keyword.attributes[:match].class == Regexp
          match = keyword if whole_line.match(keyword.attributes[:match])
        else
          raise "Unhandled :match #{keyword.attributes[:match].to_s} #{keyword.attributes[:match].class.to_s}"
        end

        break if match
      end

      match ||= default_match
    end

    if match
      # We only ever produce HTML links because this filter runs after pandoc
      link_to word, match.identifier
    else
      word
    end
  end
end
