---
title: FireQOS Commands and Variables Index
submenu: documentation
---

FireQOS Commands and Variables Index
====================================

Below is a list of FireQOS keywords and built-in variables for quick
reference.

<table class="services-table">
<% alphas = "abcdefghijklmnopqrstuvwxyz".split(//)
   while (alphas.size != 0) do
     setof4=[alphas.shift,alphas.shift,alphas.shift,alphas.shift].compact
 %>
<tr>
<%   setof4.each do |alpha| %>
<th>
<%= alpha.upcase %>
</th>
<%   end %>
</tr>
<tr>
<%   setof4.each do |alpha| %>
<td><%=
       if commands_starting("fireqos", alpha).size==0 
         "None"
       else
         commands_starting("fireqos", alpha).collect { |entry|
           html_to(entry.attributes[:command], entry.identifier)
         }.join(', ')
     end %>
</td>
<%   end %>
</tr>
<% end %>
</table>
