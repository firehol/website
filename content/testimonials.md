---
title: Testimonials
submenu: home
---

Testimonials
============

<div id="news">
<% testimonial_items.each do |entry| %>

<div class="news-item">
## <%= testimonial_date(entry) %>

<%= testimonial_content(entry) %>

<div class="testimonial-from">

<%= testimonial_from(entry) %>

</div>

</div>

<% end %>

</div>

If you like FireHOL and want to provide your own testimonial,
just <a href="/email/">drop us a quick line</a>, there's no greater
endorsment than the words of satisfied users.
