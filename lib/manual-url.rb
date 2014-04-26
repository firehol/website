require 'nokogiri'
require 'uri'

class ManualURLFilter < Nanoc::Filter
  identifier :manual_url
  type :text

  def run(content, params={})
    doc = Nokogiri::HTML(content)

    tags = {
      'a'      => 'href'
    }

    doc.search(tags.keys.join(',')).each do |node|
      url_param = tags[node.name]
      src = node[url_param]

      if (src != nil and src.match(/^\/keyword\//))
        if items[src] then
          node[url_param] = items[src].raw_content
          if items[src].attributes[:newpage]
            node["target"] = "_blank"
          end
        elsif items[src + "/"] then
          node[url_param] = items[src + "/"].raw_content
          if items[src + "/"].attributes[:newpage]
            node["target"] = "_blank"
          end
        else
          raise "No manual url: #{src}"
        end
      end
    end

    doc.to_html
  end
end
