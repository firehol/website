module FireholManualHelper
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
      params = [ :fhmanual_hol, :fhmanual_services ]
    elsif example[:keywords] == "qos"
      params = [ :fhmanual_qos ]
    else
      raise "example #{name} has unknown keyword type '#{example[:keywords]}'"
    end

    "<pre class='programlisting'>\n" +
        fhmanual_fixup(example.raw_content, *params) +
    "\n</pre>"
  end

  def fhmanual_services_by_alpha(letter)
    keys = @config[:fhmanual_service_list].keys
    matched = keys.select {|i| i.upcase.match("^#{letter.upcase}") }
    return matched.sort { |a,b| a.upcase <=> b.upcase }
  end

  ###################### Internal ######################
  private

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
    h = Hash.new
    h[/^( *)#{word}( )/] = "\\1#{fhmanual_ref(id_if_first, word)}\\2"
    h[/([^ ] )#{word}( *)/] = "\\1#{fhmanual_ref(id_if_not_first, word)}\\2"
    h
  end

  def fhmanual_prepare_int(uri)
    puts "Loading example code => uri data"
    current_html_anchor = nil
    special = Hash.new
    special['mac']  = fhmanual_special_r('mac','helpconf-mac','rule-params')
    special['dscp'] = fhmanual_special_r('dscp','helpconf-dscp','rule-params')
    special['mark'] = fhmanual_special_r('mark','helpconf-mark','rule-params')
    special['tos']  = fhmanual_special_r('tos','helpconf-tos','rule-params')

    qspecial = Hash.new
    qspecial['class']=fhmanual_special_r('class','qos-class','qos-match-params')
#    qspecial['prio'] = {
#     /^( *)class( )/ => "\\1#{fhmanual_ref('qos-class-params', 'prio')}\\2",
#     /^( *)match( )/ => "\\1#{fhmanual_ref('qos-match-params', 'prio')}\\2"
#                      }
#    qspecial['priority'] = {
#     /^( *)class( )/ => "\\1#{fhmanual_ref('qos-class-params', 'priority')}\\2",
#     /^( *)match( )/ => "\\1#{fhmanual_ref('qos-match-params', 'priority')}\\2"
#                      }
    qspecial['prio'] = {}
    qspecial['priority'] = {}
    hol_data = Hash.new
    manual_data = Hash.new
    ids_seen = Hash.new
    all_anchors = Hash.new
    errors = nil
    open(uri, "rb") do |infile|
      infile.each_line do |line|
        line.gsub(/</, "\n<").split(/\n/).each do |real_line|
          if real_line.match(/class="part" title=".*FireQOS Reference"/)
            special = qspecial
            hol_data = manual_data
            manual_data = Hash.new
            ids_seen = Hash.new
          end

          if m = real_line.match(/<a name="([^"]+)">/)
            current_html_anchor = m[1]
            all_anchors[current_html_anchor] = current_html_anchor
          end
          if m = real_line.match(/<code class="command">(.*)/)
            m[1].gsub(/ +or +/, "|").split(/\|/).each do |keyword|
            next if keyword == ""
            if special[keyword]
              special[keyword].each do |k,v|
                manual_data[k] = v
              end
              ids_seen[keyword] = current_html_anchor
            else
              link = fhmanual_ref(current_html_anchor, keyword)
              if ids_seen[keyword] != nil and ids_seen[keyword] != current_html_anchor
                puts "'#{keyword}' in examples is both '#{ids_seen[keyword]}' and '#{current_html_anchor}', define a special"
                errors = true
              else
                #puts "'#{keyword}' in examples is '#{current_html_anchor}'"
                ids_seen[keyword] = current_html_anchor
                manual_data[/^( *)#{keyword}( )/] = "\\1#{link}\\2"
                manual_data[/([ >])#{keyword}([ <]*)$/] = "\\1#{link}\\2"
                manual_data[/([ >])#{keyword}([ <])/] = "\\1#{link}\\2"
                manual_data[/^()#{keyword}()$/] = "\\1#{link}\\2"
              end
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
    ids_seen = Hash.new
    errors = nil
    open(uri, "rb") do |infile|
      infile.each_line do |line|
        if m = line.match(/<a href=".*#(service-.*)">(.*)</)
          current_html_anchor = m[1]
          link = fhmanual_ref(current_html_anchor, m[2])
          if ids_seen[m[1]] != nil and ids_seen[m[1]] != current_html_anchor
            puts "'#{m[1]}' in examples is both '#{ids_seen[m[1]]}' and '#{current_html_anchor}', define a special"
            errors = true
          else
            ids_seen[m[2]] = current_html_anchor
            manual_data[/^( *)#{m[2]}( )/] = "\\1#{link}\\2"
            manual_data[/([ >"])#{m[2]}([ <"]*)$/] = "\\1#{link}\\2"
            manual_data[/([ >"])#{m[2]}([ <"])/] = "\\1#{link}\\2"
            manual_data[/^()#{m[2]}()$/] = "\\1#{link}\\2"
          end
        end
      end
    end
    raise "Errors preparing example services" if errors
    @config[:fhmanual_services] = manual_data
    @config[:fhmanual_service_list] = ids_seen
  end

  def fhmanuals
    @items.select { |i| i[:kind] == 'example' }
  end

  def fhmanual(name)
    l = fhmanuals.select { |i| i[:name] == name }
    raise "No example named #{name}" if l.size == 0
    l.shift
  end

  def fhmanual_fixup(text, *fixup_from)
    lines = text.split("\n").collect do |line|
      line.sub!(/#([^"']*)$/, '<span class="comment">#\1</span>')
      line.sub!(/^( *)(<span class="[^"]*">)?( *)([^ =<>]*)=/, '\2<span class="var">\1\3\4</span>=')
      line.gsub!(/(\$[^ "]*)/, '<span class="var">\1</span>')
      fixup_from.each do |replace_name|
        line.gsub!(/<span class/, "<spanclass") # Prevent sub as keyword class
        front=nil
        if m = line.match(/^( *<span[^>]+> *)(.+)/)
          front = m[1]
          line = m[2]
        end
        keys=@config[replace_name].keys.sort {|a,b|b.to_s.length-a.to_s.length}
        keys.each do |k|
          if replace_name.to_s.match(/qos/) and k.to_s.match(/class/)
          end
          line.gsub!(k, @config[replace_name][k]);
        end
        if front
          line = front + line
        end
      end
      line.gsub!(/<spanclass/, "<span class")
      line
    end
    GC.start
    lines.join("\n")
  end

  def fhmanual_anchor(anchor)
    raise "No anchor list" if @config[:fhmanual_anchors] == nil
    @config[:fhmanual_anchors][anchor];
  end
end

include FireholManualHelper
