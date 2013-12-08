module NewsHelper

  def news_items
    @items.select { |item| item[:kind] == 'news' } .
             sort { |a,b| b[:date] <=> a[:date] }
  end

  def news_date(f)
     f[:date].strftime("%b %d, %Y")
  end

  def news_title(f)
    f[:title]
  end

  def news_content(f)
    f.raw_content
  end
end

include NewsHelper
