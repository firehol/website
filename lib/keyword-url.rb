class KeywordUrl < Nanoc::DataSource
  identifier :keyword_url

  def setup
    @using_pandoc = false
    if self.config[:pandoc_link_files] # See top-level nanoc.yaml
      @using_pandoc = true
      self.config[:pandoc_link_files].each { |f|
        if not File.file?(f) then @using_pandoc = false end
      }
    end
    if @using_pandoc
       return setup_links_from_pandoc(self.config[:pandoc_link_files])
    elsif File.file?(self.config[:manual_file]) and
          File.file?(self.config[:service_file])
       # Fall back to old-style HTML manual parsing
       return setup_links_from_old_html(self.config[:manual_file],
                                        self.config[:service_file])
    else
      raise "Missing files needed for link generation"
    end
    raise "Errors preparing uris" if @errors
  end

  def setup_shared_specials
    # These manual references do not get automatically generated
    replace_link('/keyword/manref/firehol/top/multi-page',
                 '/firehol-manual/')
    replace_link('/keyword/manref/firehol/top/single-page',
                 '/firehol-manual.html')
    replace_link('/keyword/manref/firehol/top/pdf',
                 '/firehol-manual.pdf')
  end

  def setup_pandoc_specials
    setup_shared_specials

    @pandoc_identifier_match = Hash.new
    @pandoc_identifier_match["/keyword/firehol/dscp/helper"] = :is_first
    @pandoc_identifier_match["/keyword/firehol/dscp/param"] = :not_first
    @pandoc_identifier_match["/keyword/firehol/mac/helper"] = :is_first
    @pandoc_identifier_match["/keyword/firehol/mac/param"] = :not_first
    @pandoc_identifier_match["/keyword/firehol/mark/helper"] = :is_first
    @pandoc_identifier_match["/keyword/firehol/mark/param"] = :not_first
    @pandoc_identifier_match["/keyword/firehol/tos/helper"] = :is_first
    @pandoc_identifier_match["/keyword/firehol/tos/param"] = :not_first
    @pandoc_identifier_match["/keyword/firehol/redirect/helper"] = :is_first
    @pandoc_identifier_match["/keyword/firehol/redirect/action"] = :not_first

    @pandoc_identifier_match["/keyword/fireqos/class/definition"] = :is_first
    @pandoc_identifier_match["/keyword/fireqos/class/param"] = :not_first

    @pandoc_identifier_match["/keyword/fireqos/prio/match"] = /match/
    @pandoc_identifier_match["/keyword/fireqos/prio/class"] = :default

    @pandoc_identifier_match["/keyword/fireqos/priority/match"] = /match/
    @pandoc_identifier_match["/keyword/fireqos/priority/class"] = :default
  end

  def setup_old_html_specials
    setup_shared_specials

    replace_link('/keyword/manref/firehol/config-file',
                 '/firehol-manual.html#firehol.conf')

    replace_link('/keyword/manref/firehol/variables-control',
                 '/firehol-manual.html#firehol-variables')

    replace_link('/keyword/manref/firehol/variables-unroutable',
                 '/firehol-manual.html#variables-available')

    replace_link('/keyword/manref/firehol/variables-activation',
                 '/firehol-manual.html#firehol-variables-activation')

    replace_link('/keyword/manref/firehol/helpme',
                 '/firehol-manual.html#firehol-opt-helpme')

    replace_link('/keyword/manref/firehol/explain',
                 '/firehol-manual.html#firehol-opt-explain')

    replace_link('/keyword/manref/firehol/debug',
                 '/firehol-manual.html#firehol-opt-debug')

    # These keywords are ambiguous so are not extracted directly from the
    # manual
    special_first_or_not('/firehol/mac',
                         'helper', 'helpconf-mac',
                         'param', 'rule-params')
    special_first_or_not('/firehol/dscp',
                         'helper', 'helpconf-dscp',
                         'param', 'rule-params')
    special_first_or_not('/firehol/mark',
                         'helper', 'helpconf-mark',
                         'param', 'rule-params')
    special_first_or_not('/firehol/tos',
                         'helper', 'helpconf-tos',
                         'param', 'rule-params')
    special_first_or_not('/firehol/redirect',
                         'helper', 'helpconf-nat',
                         'action', 'actions')

    special_first_or_not('/fireqos/class',
                         'definition', 'qos-class',
                         'param', 'qos-match-params')

    special_match_regex('/fireqos/prio', /match/,
                         'match', 'qos-match-params',
                         'class', 'qos-class-params')

    special_match_regex('/fireqos/priority', /match/,
                         'match', 'qos-match-params',
                         'class', 'qos-class-params')
  end

  def items
    setup if @items == nil
    @items
  end

  def create_item(content, attributes, identifier, params = {})
    existing = @item_hash[attributes[:url]]

    if existing
      return if content == existing[0].raw_content

      if existing[0].attributes[:match] == nil
        puts "'/keyword#{attributes[:url]}' in manual is duplicated, define a special:"
        puts "   '#{identifier}' and '#{existing[0].identifier}'"
        puts "   '#{content}' and '#{existing[0].raw_content}'"
        @errors = true
        return
      elsif attributes[:match] == nil
        return unless @using_pandoc # Duplicates happen only in HTML
      end
    end

    item = Nanoc::Item.new(content, attributes, identifier, params)
    if @using_pandoc
      item.attributes[:newpage] = false # New pages are a distraction
    else
      item.attributes[:newpage] = true  # Forgivable, as we lose menus etc.
    end
    @item_hash[item.attributes[:url]] ||= []
    @item_hash[item.attributes[:url]] << item
    @items << item
  end

  def setup_links_from_pandoc(file_list)
    @errors = nil
    @items = []
    @item_hash = {}

    puts "Loading pandoc => uri data"
    setup_pandoc_specials

    file_list.each do |file|
      open(file, "rb") do |infile|
        infile.each_line do |line|
          if m = line.match(/^\[keyword-manref-(.*)\]:\s+([^#\s]*?)\.?[0-9]?\.md#([^\s]*)\s*$/)
            keyword = m[1]
            filebase = m[2]
            anchor = m[3]
            replace_link("/keyword/manref/#{keyword.sub(/-/, '/')}",
                         "/manual/#{filebase}/\##{anchor}")
          elsif m = line.match(/^\[keyword-([^-]+)-([^-]+)-?([^-]+)?\]:\s+([^#\s]*?)\.?[0-9]?\.md#([^\s]*)\s*$/)
            # Regexp matches lines such as:
            #   [keyword-firehol-tos-param]: firehol-params.5.md#tos
            # where the -param part is optional and winds up in the
            # "disambiguate" variable"
            product = m[1]
            keyword = m[2]
            disambiguate = m[3]
            filebase = m[4]
            anchor = m[5]
            real_url = "/manual/#{filebase}/\##{anchor}"
            if product == "service"
              id = "/keyword/#{product}/#{keyword}"
              create_item real_url,
                    { :match => nil,
                      :service_name => keyword,
                      :url => "/#{product}/#{keyword}" }, id
            elsif disambiguate
              id = "/keyword/#{product}/#{keyword}/#{disambiguate}"
              create_item real_url,
                    { :match => @pandoc_identifier_match[id],
                      :url => "/#{product}/#{keyword}" }, id
            else
              id = "/keyword/#{product}/#{keyword}"
              create_item real_url,
                    { :match => nil,
                      :url => "/#{product}/#{keyword}" }, id
            end
          end
        end
      end
    end

    @items
  end

  def setup_links_from_old_html(manual_html, service_html)
    @errors = nil
    @items = []
    @item_hash = {}


    puts "Loading manual => uri data"
    setup_old_html_specials
    prefix = "/firehol/"
    current_html_anchor = nil
    open(self.config[:manual_file], "rb") do |infile|
      infile.each_line do |line|
        line.gsub(/</, "\n<").split(/\n/).each do |real_line|
          if real_line.match(/class="part" title=".*FireQOS Reference"/)
            prefix = "/fireqos/"
          end

          if m = real_line.match(/<a name="([^"]+)">/)
            current_html_anchor = m[1]
          end

          if m = real_line.match(/<code class="command">(.*)/)
            m[1].gsub(/ +or +/, "|").split(/\|/).each do |keyword|
              next if keyword == ""
              create_item "/firehol-manual.html\##{current_html_anchor}",
                    { :match => nil,
                      :url => prefix + keyword },
                    "/keyword" + prefix + keyword
            end
          end
        end
      end
    end
    raise "No fireqos information" unless prefix == "/fireqos/";

    puts "Loading services => uri data"
    prefix = "/service/"
    open(self.config[:service_file], "rb") do |infile|
      infile.each_line do |line|
        if m = line.match(/<a href=".*#(service-.*)">(.*)</)
          current_html_anchor = m[1]
          keyword = m[2]
          create_item "/firehol-manual.html\##{current_html_anchor}",
                { :match => nil,
                  :service_name => keyword,
                  :url => prefix + keyword },
                "/keyword" + prefix + keyword
        end
      end
    end

    @items
  end

private
  def special_first_or_not(keyword, ref_if_first, id_if_first,
                                    ref_if_not_first, id_if_not_first)
    # These special cases are keywords that mean something different
    # at the beginning of a configuration line than elsewhere in the line
    create_item "/firehol-manual.html\##{id_if_first}",
                    { :match => :is_first,
                      :url => keyword },
                    "/keyword" + keyword + "/" + ref_if_first

    create_item "/firehol-manual.html\##{id_if_not_first}",
                    { :match => :not_first,
                      :url => keyword },
                    "/keyword" + keyword + "/" + ref_if_not_first
  end

  def special_match_regex(keyword, regex, ref_if_match, id_if_match,
                                         ref_if_default, id_if_default)
    create_item "/firehol-manual.html\##{id_if_match}",
                    { :match => regex,
                      :url => keyword },
                    "/keyword" + keyword + "/" + ref_if_match

    create_item "/firehol-manual.html\##{id_if_default}",
                    { :match => :default,
                      :url => keyword },
                    "/keyword" + keyword + "/" + ref_if_default
  end

  def replace_link(keyword, id)
    create_item id, { :match => :none }, keyword
  end
end
