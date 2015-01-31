---
title: FireHOL Border Router Tutorial
submenu: documentation
---

FireHOL Border Router Tutorial
==============================

Dealing with a lot of network interfaces can quickly mess up your
ruleset. One wait to avoid this is having an outbound perspective. Think
about you are sitting on your router, holding a network packet in your
hand that you want to place in one of your network interfaces send
queue. This is where your <%=
html_to('router','/keyword/firehol/router') %> kicks in. For this
example we assume a
[RIR](http://en.wikipedia.org/wiki/Regional_Internet_registry) has
dedicated us a provider-independent IPv4 prefix 198.18.0.0/15 and an
IPv6 prefix 2001:0002::/48 which we have to announce to our providers.

1. Identify network interfaces
------------------------------

Let us think about an border router having three Internet uplinks
attached and that is connected to your internal DMZ network by one NIC.

Name NIC  Peering  Note
---- ---- -------  ----
ISP1 eth0 BGP      traffic to ISP2 may transit
ISP2 eth1 OSPF     traffic to ISP1 may transit
ISP3 ppp0 BGP      connect via phy. NIC eth2
DMZ  eth3 &nbsp;   &nbsp;

We will refer to this layout throughout.

2. Ruleset
----------

Now it is time to start writing the FireHOL configuration file. Let us
define the interface statements.

<%= include_example("tutorial-border-router-01") %>

Router ISP1

<%= include_example("tutorial-border-router-02") %>

Router ISP2

<%= include_example("tutorial-border-router-03") %>

Router ISP3

<%= include_example("tutorial-border-router-04") %>

Router DMZ

<%= include_example("tutorial-border-router-05") %>
