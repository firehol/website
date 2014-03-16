module FireholManualHelper
  require 'strscan'

  def fhmanual_prepare(manual,services)
    fhmanual_prepare_int(manual)
    fhmanual_prepare_services_int(services)
  end

  def fh_manref(id, text)
     if id != nil and fhmanual_anchor(id) == nil
       raise "firehol manual has no anchor '#{id}'"
     end
     fhmanual_ref(id,text)
  end

  def fhmanual_example(name)
     example = fhmanual(name)

    if example[:keywords] == nil
      raise "example #{name} is missing a keyword declaration (qos/hol)"
    end

    if example[:keywords] == "hol"
      sections = [ @config[:fhmanual_hol], @config[:fhmanual_services] ]
    elsif example[:keywords] == "qos"
      sections = [ @config[:fhmanual_qos] ]
    else
      raise "example #{name} has unknown keyword type '#{example[:keywords]}'"
    end

    "<pre class='programlisting'>\n" +
        fhmanual_fixup(example.raw_content, sections) +
    "\n</pre>"
  end

  def fhmanual_services_by_alpha(letter)
    keys = @config[:fhmanual_services].keys
    matched = keys.select {|i| i.upcase.match("^#{letter.upcase}") }
    return matched.sort { |a,b| a.upcase <=> b.upcase }
  end

  ###################### Internal ######################
  private

  class SpecialManualReference
    attr_accessor :match
    attr_accessor :url

    def applies?(is_first_word,  line)
      if @match == :is_first
        is_first_word ? true : false
      elsif @match == :is_not_first
        is_first_word ? false : true
      elsif @match and line.match(@match)
        true
      else
        false
      end
    end
  end

  class ManualReference
    attr_accessor :keyword
    attr_accessor :url
    attr_accessor :anchor
    attr_accessor :specials
  end

  def fhmanual_ref(id, text, url = nil)
     if url == nil
       url = if id == nil or id == ""
                "/manual"
             else
                "/firehol-manual.html"
             end
     end

     if id == nil or id == ""
     then
       "<a href='#{url}'>#{text}</a>"
     else
       "<a target='_blank' href='#{url}\##{id}'>#{text}</a>"
     end
  end

  def fhmanual_special_r(word, id_if_first, id_if_not_first)
    # These special cases are keywords that mean something different
    # at the beginning of a configuration line than elsewhere in the line
    w1 = SpecialManualReference.new
    w1.match = :is_first
    w1.url = fhmanual_ref(id_if_first, word)

    w2 = SpecialManualReference.new
    w2.match = :is_not_first
    w2.url = fhmanual_ref(id_if_not_first, word)

    manref = ManualReference.new
    manref.keyword = word
    manref.specials = [ w1, w2 ]
    manref
  end

  def fhmanual_special_q(word)
    w1 = SpecialManualReference.new
    w1.match = /match/;
    w1.url = fhmanual_ref('qos-match-params', word)

    w2 = SpecialManualReference.new
    w2.match = /./;
    w2.url = fhmanual_ref('qos-class-params', word)

    manref = ManualReference.new
    manref.keyword = word
    manref.specials = [ w1, w2 ]
    manref
  end

  def fhmanual_prepare_int(uri)
    puts "Loading example code => uri data"
    current_html_anchor = nil

    hol_data = nil
    manual_data = Hash.new
    manual_data['mac'] =fhmanual_special_r('mac','helpconf-mac','rule-params')
    manual_data['dscp']=fhmanual_special_r('dscp','helpconf-dscp','rule-params')
    manual_data['mark']=fhmanual_special_r('mark','helpconf-mark','rule-params')
    manual_data['tos'] =fhmanual_special_r('tos','helpconf-tos','rule-params')
    all_anchors = Hash.new
    errors = nil
    open(uri, "rb") do |infile|
      infile.each_line do |line|
        line.gsub(/</, "\n<").split(/\n/).each do |real_line|
          if real_line.match(/class="part" title=".*FireQOS Reference"/)
            hol_data = manual_data
            manual_data = Hash.new
            manual_data['class'] = fhmanual_special_r('class','qos-class',
                                                      'qos-match-params')
            manual_data['prio'] = fhmanual_special_q('prio')
            manual_data['priority'] =fhmanual_special_q('priority')
          end

          if m = real_line.match(/<a name="([^"]+)">/)
            current_html_anchor = m[1]
            all_anchors[current_html_anchor] = current_html_anchor
          end
          if m = real_line.match(/<code class="command">(.*)/)
            m[1].gsub(/ +or +/, "|").split(/\|/).each do |keyword|
              next if keyword == ""
              if manual_data[keyword]
                if not manual_data[keyword].specials and
                       manual_data[keyword].anchor != current_html_anchor
                  puts "'#{keyword}' in examples is both '#{manual_data[keyword].anchor}' and '#{current_html_anchor}', define a special"
                  errors = true
                end
              else
                manref = ManualReference.new
                manref.keyword = keyword
                manref.url = fhmanual_ref(current_html_anchor, keyword)
                manref.anchor = current_html_anchor
                manual_data[keyword] = manref
              end
            end
          end
        end
      end
    end
    if hol_data == nil
      raise "Did not find FireQOS reference"
    end
    raise "Errors preparing examples" if errors
    @config[:fhmanual_hol] = hol_data
    @config[:fhmanual_qos] = manual_data
    @config[:fhmanual_anchors] = all_anchors
  end

  def fhmanual_prepare_services_int(uri)
    puts "Loading example services => uri data"
    current_html_anchor = nil
    manual_data = Hash.new
    errors = nil
    open(uri, "rb") do |infile|
      infile.each_line do |line|
        if m = line.match(/<a href=".*#(service-.*)">(.*)</)
          current_html_anchor = m[1]
          keyword = m[2]
          if manual_data[keyword]
            if manual_data[keyword].anchor != current_html_anchor
              puts "'#{keyword}' in examples is both '#{manual_data[keyword].anchor}' and '#{current_html_anchor}', define a special"
              errors = true
            end
          else
            manref = ManualReference.new
            manref.keyword = keyword
            manref.url = fhmanual_ref(current_html_anchor, keyword)
            manref.anchor = current_html_anchor
            manual_data[keyword] = manref
          end
        end
      end
    end
    raise "Errors preparing example services" if errors
    @config[:fhmanual_services] = manual_data
  end

  def fhmanuals
    @items.select { |i| i[:kind] == 'example' }
  end

  def fhmanual(name)
    l = fhmanuals.select { |i| i[:name] == name }
    raise "No example named #{name}" if l.size == 0
    l.shift
  end

  def fhmanual_fixup(text, sections)
    outtext = ""
    lines = text.split("\n").collect do |line|
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

        sections.each do |manrefs|
          manref = manrefs[word]
          if manref and manref.specials
            manref.specials.each do |special|
              if special.applies?(first_word, line)
                word = special.url
                break
              end
            end
          elsif manref and manref.url
            word = manref.url
          end
        end
        outtext += word
        first_word = false if is_word
      end
      outtext += "\n"
    end
    outtext
  end

  def fhmanual_anchor(anchor)
    raise "No anchor list" if @config[:fhmanual_anchors] == nil
    @config[:fhmanual_anchors][anchor];
  end
end

include FireholManualHelper
