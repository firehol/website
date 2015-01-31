module FireholExamples
  def include_example(name, *param_array)
    spaces = param_array.first || ""
    examples = @items.select { |i| i[:kind] == 'example' && i[:name] == name }
    raise "No example named #{name}" if examples.size < 1
    raise "Multiple examples named #{name}" if examples.size > 1

    example = examples[0]

    if example[:keyword] == nil
      raise "example #{name} is missing a keyword declaration (fireqos/firehol)"
    end

    if example[:keyword] != "firehol" and example[:keyword] != "fireqos"
      raise "example #{name} has unknown keyword type '#{example[:keyword]}'"
    end

    if @item[:extension] and @item[:extension].end_with? "md"
      prefix = "\n#{spaces}~~~~ {.#{example[:keyword]}}\n"
      suffix = if example.raw_content.end_with? "\n"
                 ""
               else
                 "\n"
               end + "#{spaces}~~~~~\n\n"
    else
      prefix = "<pre class='#{example[:keyword]}'><code>"
      suffix = "\n</code></pre>\n"
    end
    prefix + example.raw_content.gsub(/^/, spaces) + suffix
  end
end

include FireholExamples
