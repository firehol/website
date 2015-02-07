module TestimonialHelper

  def testimonial_items
    @items.select { |item| item[:kind] == 'testimonial' } .
             sort { |a,b| b[:date] <=> a[:date] }
  end

  def testimonial_full_date(f)
     d = DateTime.parse f[:date]
     d.strftime("%a %b %d, %Y %H:%M")
  end

  def testimonial_date(f)
     d = DateTime.parse f[:date]
     d.strftime("%b %d, %Y")
  end

  def testimonial_from(f)
     f[:from]
  end

  def testimonial_content(f)
    f.raw_content
  end

  def testimonial_title(f)
    f.raw_content.split(/\n/)[0][0..30] + "..."
  end
end

include TestimonialHelper
