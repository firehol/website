---
group: 0002-Running
title: 0006-Why I cannot use the service definitions in helpers?
id: service-definitions
kind: faq
---

As you have noted, the [service definitions](/services/) cannot be used
in helper statements (mainly NAT). The reason is that currently
FireHOL's core logic is limited to one iptables table (filter). To
extend this to all iptables tables a new core logic is needed that
should be based on something that can be shared across all iptables
tables. The only such thing today is MARKs. MARKs are also used for QoS
unifying all major traffic management applications.

I have made a few experiments with MARKs but I stuck because there are
bugs in the iptables logic when using MARKs. These bugs exist in most
kernels distributed today with the main Linux distributions.
