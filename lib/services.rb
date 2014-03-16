module FireholServices
  def services_starting(letter)
    @items.select { |item|
      item.attributes[:service_name] &&
         item.attributes[:service_name].upcase.start_with?(letter.upcase)
    } .sort { |a,b| a.attributes[:service_name].upcase <=> b.attributes[:service_name].upcase }
  end
end

include FireholServices
