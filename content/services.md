---
title: Services
submenu: documentation
---

FireHOL Service Index
=====================

Below is the list of FireHOL supported services. You can create new
services and overwrite all of the existing ones (including those
marked as complex).
See the [Adding Services Guide](/guides/adding-services/).

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
       if services_starting(alpha).size==0 
         "None"
       else
         services_starting(alpha).collect { |entry|
           html_to(entry.attributes[:service_name], entry.identifier)
         }.join(', ')
     end %>
</td>
<%   end %>
</tr>
<% end %>
</table>

If you find an incorrect or missing definition, please report
it so that it can be resolved for all users.
