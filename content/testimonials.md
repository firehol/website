---
title: Testimonials
submenu: home
---

Testimonials
============

<div id="news">
<% testimonial_items.each do |entry| %>

<div class="news-item">
### <%= testimonial_full_date(entry) %>

<%= testimonial_content(entry) %>

<div class="testimonial-from">

<%= testimonial_from(entry) %>

</div>

</div>

<% end %>

</div>

There's no greater endorsement than the words of satisfied users.
So, if you like FireHOL and want to provide your own testimonial,
just [drop one of us a quick email](/support/#email) and let us know
you're happy for us to publish it.
