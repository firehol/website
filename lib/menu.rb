module MenuHelper

  def submenu_class(menu, item_belongs_in)
     if menu == item_belongs_in
         "openbydefault"
     else
         "closedbydefault"
     end
  end
end

include MenuHelper
