class KeywordUrl < Nanoc::DataSource
  identifier :keyword_url

  def setup
    error=nil
    self.config[:pandoc_link_files].each { |f|
      if not File.file?(f) then error="Missing #{f} link generation" end
    }
    return setup_links_from_pandoc(true, self.config[:pandoc_link_files]) unless error

    self.config[:pandoc_link_old].each { |f|
      raise error if not File.file?(f)
    }
    return setup_links_from_pandoc(false, self.config[:pandoc_link_old])
  end

  def setup_pandoc_specials
    # These manual references do not get automatically generated
    replace_link('/keyword/manref/firehol/top/multi-page',
                 '/firehol-manual/')
    replace_link('/keyword/manref/firehol/top/single-page',
                 '/firehol-manual.html')
    replace_link('/keyword/manref/firehol/top/pdf',
                 '/firehol-manual.pdf')

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
      end
    end

    item = Nanoc::Item.new(content, attributes, identifier, params)
    item.attributes[:newpage] = false # New pages are a distraction
    @item_hash[item.attributes[:url]] ||= []
    @item_hash[item.attributes[:url]] << item
    @items << item
  end

  def setup_links_from_pandoc(separate_manuals, file_list)
    @errors = nil
    @items = []
    @item_hash = {}

    puts "Loading pandoc => uri data"
    setup_pandoc_specials

    file_list.each do |file|
      open(file, "rb") do |infile|
        infile.each_line do |line|
          if m = line.match(/^\[keyword-manref-(.*)\]:\s+([^#\s]*?)(#[^\s]*)?\s*$/)
            keyword = m[1]
            filebase = m[2]
            anchor = m[3] == nil ? "" : m[3]
            replace_link("/keyword/manref/#{keyword.sub(/-/, '/')}",
                         "#{filebase}#{anchor}")
          elsif m = line.match(/^\[keyword-([^-]+)-([^-]+)-?([^-]+)?\]:\s+([^#\s]*?)(#[^\s]*)?\s*$/)
            # Regexp matches lines such as:
            #   [keyword-firehol-tos-param]: firehol-params.5.md#tos
            # where the -param part is optional and winds up in the
            # "disambiguate" variable"
            product = m[1]
            keyword = m[2]
            disambiguate = m[3]
            filebase = m[4]
            anchor = m[5] == nil ? "" : m[5]
            real_url = "#{filebase}#{anchor}"
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
                      :command => "#{keyword} (#{disambiguate})",
                      :product => product,
                      :url => "/#{product}/#{keyword}" }, id
            else
              id = "/keyword/#{product}/#{keyword}"
              create_item real_url,
                    { :match => nil,
                      :command => keyword,
                      :product => product,
                      :url => "/#{product}/#{keyword}" }, id
            end
          end
        end
      end
    end

    @items
  end

private
  def replace_link(keyword, id)
    create_item id, { :match => :none }, keyword
  end
end
