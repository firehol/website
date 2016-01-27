---
title: Upgrading configuration
submenu: documentation
---

Upgrading your configuration
============================

FireHOL maintains compatibility with older configurations by using a
configuration version number. When a significant change to configuration
occurs, the expected number is incremented.

If you have been directed to this page when running FireHOL, the version
number expected by FireHOL is higher than the one used in your
configuration.

You should review your configuration to ensure it will still work as you
expect and then update the version number to the expected version.

-   [To 6 from 5 (changed at FireHOL 2.0.0-pre6)](#config-version-6) -
    Adds IPv6 support

* * * * *

Config Version 6
-----------------

* adds IPv6 support

The configuration version of FireHOL 2.0.0-pre6 and later has been
updated from 5 to 6.

In summary, from FireHOL v2.0.0-pre6 adds combined IPv4/IPv6 support.
This document helps you update your configuration to the latest version
with no change in IPv4 behaviour (note: IPv6 will be completely blocked).

Once you have completed it you can optionally follow the
[FireHOL IPv6 Setup tutorial](/tutorial/firehol-ipv6/) to extend the
firewall to cover IPv6 as well as IPv4.

We will use this simple example and mark everything as IPv4 only:

<%= include_example('upgrade-6-03') %>

Anything in a configuration can be labelled `ipv4`:

<%= include_example('upgrade-6-02') %>

In addition interfaces and routers can be written as `interface4` and
`router4`. All sub-commands of an IPv4 router or interface will inherit
the fact they are IPv4, so we can rewrite out example as this:

<%= include_example('upgrade-6-04') %>

Finally, update your version line (or add one):

<%= include_example('upgrade-6-01') %>

The only behaviour change to your version 5 config is that your host
will now drop IPv6 packets where before they were allowed unless you
took separate steps to block them. If you want to allow IPv6 traffic,
check out the [FireHOL IPv6 Setup tutorial](/tutorial/firehol-ipv6/).
