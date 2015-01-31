---
group: 0002-Running
title: 0002-How do I match virtual interfaces such as eth0:1?
id: virtual-interfaces
kind: faq
---

`eth0:1`{.interface} is not really a virtual Ethernet device. The
`eth0:1`{.interface} is just a naming convention for tools such as
ifconfig to be able to use multiple IP addresses on a single interface.

If you have interfaces with these names, it is for the purpose of having
multiple IP addresses on an interface. Netfilter does not recognise the
aliases. You cannot use them in your firewall and must match on the IP
address instead.

In practice, iptables does not prevent you creating rules to try to
match `eth0:1`{.interface}. However, when running, the incoming packets
will be seen as from `eth0`{.interface} and will match only the
`eth0`{.interface} rules. FireHOL inherits this behaviour.

Note that VLAN interfaces such as `eth0.1`{.interface} are genuine
interfaces that will work as expected within firewall rules.
