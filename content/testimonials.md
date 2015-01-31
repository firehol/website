---
title: Testimonials
submenu: home
---

Testimonials
============

<div id="news">
  <% testimonial_items.each do |entry| %>
  <div class="news_item">
    <h2><%= testimonial_date(entry) %></h2>
    <%= testimonial_content(entry) %>
    <p class="testimonial_from"/><%= testimonial_from(entry) %></p>
  </div>
  <% end %>
</div>

If you like FireHOL and want to provide your own testimonial,
just <a href="/email/">drop us a quick line</a>, there's no greater
endorsment than the words of satisfied users.
