module MenuHelper

  def submenu_class(menu, item_belongs_in)
     if menu == item_belongs_in
         "openbydefault"
     else
         "closedbydefault"
     end
  end

  def submenu_ind(menu, item_belongs_in)
     if submenu_class(menu, item_belongs_in) == "openbydefault"
       "<a class=\"toggle\" name=\"#{menu}\">[-]</a>"
     else
       "<a class=\"toggle\" name=\"#{menu}\">[+]</a>"
     end
  end
end

include MenuHelper
