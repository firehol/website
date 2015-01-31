module MenuHelper

  def li_active(menu, item_belongs_in)
     if menu == item_belongs_in
       '<li class="active">'
     else
       '<li>'
     end
  end
end

include MenuHelper
