---
title: Frequently Asked Questions
submenu: documentation
---

FAQ
===

FireHOL - Frequently Asked Questions

<% faq_groups.each do |group| %>
<h2><%= group.sub(/[^-]*-/, "") %></h2>
<ul>
  <% faqs_in_group(group).each do |entry| %>
  <li><a href="#<%= faq_id(entry) %>"><%= faq_title(entry) %></a></li>
  <% end %>
</ul>
<% end %>

<% faq_groups.each do |group| %>
<% faqs_in_group(group).each do |entry| %>
<h3 id="<%= faq_id(entry) %>"><%= faq_title(entry) %></h3>
<%= entry.compiled_content %>
<p><a href="/faq/">^ top</a></p>
<% end %>
<% end %>
