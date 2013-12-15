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
    "<pre class='programlisting'>\n" +
        fhmanual_fixup(fhmanual(name).raw_content) +
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
    current_id = nil
    special = Hash.new
    special['mac'] = fhmanual_special_r('mac','helpconf-mac','rule-params')
    special['dscp'] =fhmanual_special_r('dscp','helpconf-dscp','rule-params')
    special['mark'] =fhmanual_special_r('mark','helpconf-mark','rule-params')
    special['tos'] = fhmanual_special_r('tos','helpconf-tos','rule-params')
    manual_data = Hash.new
    ids_seen = Hash.new
    all_anchors = Hash.new
    errors = nil
    open(uri, "rb") do |infile|
      infile.each_line do |line|
        line.gsub(/</, "\n<").split(/\n/).each do |real_line|
          if m = real_line.match(/<a name="([^"]+)">/)
            current_id = m[1]
            all_anchors[current_id] = current_id
          end
          if m = real_line.match(/<code class="command">(.*)/)
            if special[m[1]]
              special[m[1]].each do |k,v|
                manual_data[k] = v
              end
              ids_seen[m[1]] = current_id
            else
              link = fhmanual_ref(current_id, m[1])
              if ids_seen[m[1]] != nil and ids_seen[m[1]] != current_id
                puts "'#{m[1]}' in examples is both '#{ids_seen[m[1]]}' and '#{current_id}', define a special"
                errors = true
              else
                ids_seen[m[1]] = current_id
                manual_data[/^( *)#{m[1]}( )/] = "\\1#{link}\\2"
                manual_data[/([ >])#{m[1]}([ <]*)$/] = "\\1#{link}\\2"
                manual_data[/([ >])#{m[1]}([ <])/] = "\\1#{link}\\2"
                manual_data[/^()#{m[1]}()$/] = "\\1#{link}\\2"
              end
            end
          end
        end
      end
    end
    raise "Errors preparing examples" if errors
    @config[:fhmanual_data] = manual_data
    @config[:fhmanual_anchors] = all_anchors
  end

  def fhmanual_prepare_services_int(uri)
    puts "Loading example services => uri data"
    current_id = nil
    manual_data = Hash.new
    ids_seen = Hash.new
    errors = nil
    open(uri, "rb") do |infile|
      infile.each_line do |line|
        if m = line.match(/<a href=".*#service-(.*)">(.*)</)
          current_id = m[1]
          link = fhmanual_ref(current_id, m[2])
          if ids_seen[m[1]] != nil and ids_seen[m[1]] != current_id
            puts "'#{m[1]}' in examples is both '#{ids_seen[m[1]]}' and '#{current_id}', define a special"
            errors = true
          else
            ids_seen[m[2]] = current_id
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

  def fhmanual_fixup(text)
    t = text
    keys=@config[:fhmanual_data].keys.sort {|a,b|b.to_s.length-a.to_s.length}
    keys.each do |k|
      t = t.gsub(k, @config[:fhmanual_data][k]);
    end
    keys=@config[:fhmanual_services].keys.sort {|a,b|b.to_s.length-a.to_s.length}
    keys.each do |k|
      t = t.gsub(k, @config[:fhmanual_services][k]);
    end
    t
  end

  def fhmanual_anchor(anchor)
    raise "No anchor list" if @config[:fhmanual_anchors] == nil
    @config[:fhmanual_anchors][anchor];
  end
end

include FireholManualHelper
