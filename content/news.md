---
title: News
submenu: home
---

Latest News
===========

<div id="news">

  <% news_items.each do |entry| %>
  <div class="news_item">
    <h2><%= news_date(entry) %> -
        <span class="news_title"><%= news_title(entry) %></span></h2>
    <%= news_content(entry) %>
  </div>
  <% end %>

</div>
