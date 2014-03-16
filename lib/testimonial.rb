module TestimonialHelper

  def testimonial_items
    @items.select { |item| item[:kind] == 'testimonial' } .
             sort { |a,b| b[:date] <=> a[:date] }
  end

  def testimonial_date(f)
     d = DateTime.parse f[:date]
     d.strftime("%a %b %d, %Y %H:%M")
  end

  def testimonial_from(f)
     f[:from]
  end

  def testimonial_content(f)
    f.raw_content
  end
end

include TestimonialHelper
