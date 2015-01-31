---
title: News
submenu: home
---

Latest News
===========

<div id="news">
<% news_items.each do |entry| %>

<div class="news-item">
## <%= news_date(entry) %> - <%= news_title(entry) %>

<%= news_content(entry) %>

</div>
<% end %>

</div>
