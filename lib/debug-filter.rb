class DebugFilter < Nanoc::Filter
  identifier :debug_filter
  type :text

  def run(content, params={})
    puts content
    content
  end
end
