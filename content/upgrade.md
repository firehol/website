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
updated from 5 to 6. Review your configuration and then update your
version line to:

<%= include_example('upgrade-6-01') %>

FireHOL v2.0.0-pre6 adds combined IPv6/IPv6 support. When upgrading from
an earlier version of FireHOL there are two main changes you need to
allow for: IPv4/IPv6 address specification and system differences that
cannot be hidden.

IPv4 and IPv6 addresses are different, and in FireHOL v2 you must
specify them explicitly. To ensure the rules are applied evenly, if you
specify one you must specify both, or mark the whole rule as IPv4 or
IPv6 only.

Not every option for IPv4 exists in IPv6 e.g. NAT and masquerading are
not available until Linux 3.7 and may not be enabled on your system. If
you do not have support for a rule in IPv6 on your system, you will need
to mark it as IPv4 only.

To allow you to apply something to IPv4 or IPv6 only, anything in a
configuration can be labelled. For instance to mark something as IPv4
only, write it as:

<%= include_example('upgrade-6-02') %>

Some commands (interface, router, client, server, route, group) have
been given special names e.g. interface4/interface6 which are equivalent
to labelling them with ipv4 or ipv6.

We will show how to adapt this simple config in a few possible ways:

<%= include_example('upgrade-6-03') %>

-   ### No IPv6 at all

    If you want to upgrade quickly and not deal with IPv6 at all, you
    can specify IPv4 interfaces and routers explicitly within FireHOL,
    so just rewrite to this:

    <%= include_example('upgrade-6-04', "    ", "    ") %>

    The only behaviour change to your version 5 config is that your host
    will now drop IPv6 packets where before they were allowed unless you
    took steps to block them.

-   ### Rules with no IPv6 equivalent

    If you do not have any IPv6 addresses for particular rules, specify
    them as only applying to IPv4:

    <%= include_example('upgrade-6-05', "    ") %>

    It is possible to also add rules which only apply to IPv6.

-   ### Rules which an IPv6 address can be added to

    If you do have an IPv6 address for a particular rule, specify it
    explicitly with src4/src6 and dst4/dst6 e.g.:

    <%= include_example('upgrade-6-06', "    ") %>

    The FireHOL variables such as \$UNROUTABLE\_IPS will work
    automatically in both contexts, so you can still write:

    <%= include_example('upgrade-6-07', "    ") %>

    If you want to combine this with your own IPs or ranges, you will
    need to be explicit, either with:

    <%= include_example('upgrade-6-08', "    ") %>

    or the equivalent:

    <%= include_example('upgrade-6-09', "    ") %>

    which is more explicit.

-   ### Specific IPv4/IPv6 services

    Some services only make sense as IPv4 or IPv6 and are automatically
    switched to that mode. They cannot be included in blocks of rules
    specified to the opposite mode.

    IPv4 only: <%= html_to('dhcp','/keyword/service/dhcp') %> and
    <%= html_to('timestamp','/keyword/service/timestamp') %>.

    IPv6 only: <%= html_to('dhcpv6','/keyword/service/dhcpv6') %>,
    <%= html_to('ipv6error','/keyword/service/ipv6error') %>, <%=
    html_to('ipv6neigh','/keyword/service/ipv6neigh') %>, and <%=
    html_to('ipv6router','/keyword/service/ipv6router') %>.

-   ### Important ICMP differences

    Various ICMPv6 messages need to be explicitly allowed for correct
    operation of IPv6. Firstly, certain ICMPv6 error messages must be
    enabled.

    <%= include_example('upgrade-6-10', "    ") %>

    Incoming and outgoing rules are different and are set up
    automatically. Do not use `client ipv6error accept` except in a <%=
    html_to('router','/keyword/firehol/router') %> where the outface
    is the "inside" of your firewall. See the <%=
    html_to('ipv6error','/keyword/service/ipv6error') %> documentation
    for more information.

    The remaining ICMPv6 messages should generally not be used in
    FireHOL router definitions, since the information they convey should
    be kept to the local network.

    To allow hosts to communicate with one another over IPv6, network
    neighbour solicitation/advertisement messages (which do in IPv6 what
    ARP does in IPv4) must be enabled on interfaces.

    <%= include_example('upgrade-6-10a', "    ") %>

    To allow network route auto-discovery, router
    solicitation/advertisement messages must be enabled on interfaces as
    a client.

    <%= include_example('upgrade-6-11', "    ") %>

    You can accept these messages from multiple interfaces, for instance
    on "home" above, if there are multiple IPv6 routes available.

    If your machine will be routing IPv6, it will also need to be able
    to send router advertisement messages from the relevant interface(s).

    <%= include_example('upgrade-6-12', "    ") %>


