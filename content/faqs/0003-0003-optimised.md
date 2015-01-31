---
group: 0003-General
title: 0003-Is the produced iptables firewall optimised?
id: optimisation
kind: faq
---

You have to understand that FireHOL is a generic tool. As such, you gain
something and you loose something. Except the fact that all FireHOL
configuration rules take one iptables chain (that is one "jump") the
produced rules are fully optimised. In many cases, this "jump" optimises
the firewall even further (for example in interface and router
statements), while in other cases the "jumps" could be moved to a place
where they are really necessary (it is not possible to avoid them). The
good thing is that these "jumps" are not so expensive. So, although
there is some room for improvement, I have reports from users saying
that a huge FireHOL firewall did not introduce a noticeable increase in
CPU utilisation compared to a hand made firewall, for the same traffic.

For the moment, I prefer to keep all the "jumps" there, since it makes
the iptables rules a lot more clear and easy to understand. If you
believe that I should work on this and you can prove that the "jumps"
that could be moved deeper are really expensive at the place they are
now, send me a note and I'll do my best.

If you are so interested about performance, you should know that FireHOL
places all rules in the iptables firewall, in the same order they appear
in the configuration file. So placing your most heavy interface at the
top, and within this interface the most heavy service first will really
save a lot of processing for iptables.
