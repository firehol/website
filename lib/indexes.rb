module IndexPages
  def services_starting(letter)
    @items.select { |item|
      item.attributes[:service_name] &&
         item.attributes[:service_name].upcase.start_with?(letter.upcase)
    } .sort { |a,b| a.attributes[:service_name].upcase <=> b.attributes[:service_name].upcase }
  end

  def commands_starting(product, letter)
    @items.select { |item|
      product == item.attributes[:product] &&
      item.attributes[:command] &&
         item.attributes[:command].upcase.start_with?(letter.upcase)
    } .sort { |a,b| a.attributes[:command].upcase <=> b.attributes[:command].upcase }
  end
end

include IndexPages
