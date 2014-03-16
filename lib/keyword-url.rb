class KeywordUrl < Nanoc::DataSource
  identifier :keyword_url

  def setup_specials
    # These are general manual references, which do not get automatically
    # generated
    replace_link('/keyword/manref/firehol/top/multi-page',
                 '/firehol-manual/')
    replace_link('/keyword/manref/firehol/top/single-page',
                 '/firehol-manual.html')
    replace_link('/keyword/manref/firehol/top/pdf',
                 '/firehol-manual.pdf')

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
        puts "'#{identifier}' in manual is both '#{content}' and '#{existing[0].raw_content}', define a special"
        @errors = true
        return
      elsif attributes[:match] == nil
        return
      end
    end

    item = Nanoc::Item.new(content, attributes, identifier, params)
    @item_hash[item.attributes[:url]] ||= []
    @item_hash[item.attributes[:url]] << item
    @items << item
  end

  def setup
    @errors = nil
    @items = []
    @item_hash = {}


    puts "Loading manual => uri data"
    setup_specials
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

    raise "Errors preparing uris" if @errors
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
