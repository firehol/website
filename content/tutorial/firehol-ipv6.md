---
title: FireHOL IPv6 Setup
submenu: documentation
---

# FireHOL IPv6 Setup

First, get an IPv4 setup operational. If you are starting from scratch,
try with the [new user](/tutorial/firehol-new-user/) or some other
[tutorial](/documentation/#firehol).

Contents:

* [Notes on IPv4 and IPv6][]
* [Restricting commands to a particular version][]
* [Enabling Basic IPv6 Networking][]
* [Upgrading Existing Interfaces and Routers][]

## Notes on IPv4 and IPv6

IPv4 and IPv6 addresses are different, and in FireHOL v2+ you must
specify them explicitly. To ensure the rules are applied evenly, if you
specify one you must specify both, or mark the whole rule as IPv4 or
IPv6 only.

Not every option for IPv4 exists in IPv6 e.g. NAT and masquerading are
not available until Linux 3.7 and may not be enabled on your system. If
you do not have support for a rule in IPv6 on your system, you will need
to mark it as IPv4 only.

## Restricting commands to a particular version

To allow you to apply something to IPv4 or IPv6 only, anything in a
configuration can be labelled. For instance to mark something as IPv4
only, write it as:

<%= include_example('upgrade-6-02') %>

Most commands (e.g. `interface`, `router`, `client`, `server`, `route`,
`group`) have been given special names
e.g. `interface4`/`interface6`/`interface46` which are equivalent
to labelling them with `ipv4` or `ipv6` or `both`.

## Enabling Basic IPv6 Networking

Unlike IPv4 which has separate protocols for host resolution, IPv6
makes use of ICMPv6 messages. The IPv4 resolution protocols (ARP) were
not filtered by netfilter (and therefore by FireHOL) but the IPv6 ones
are.

This means explicit steps must be taken to allow them. Note that the
service <%= html_to('all','/keyword/service/all') %> **does not** enable
these messages, you must enable them as explained below.

Further, these ICMPv6 messages are sent to multicast addresses which means
if you use `src` or `dst` values in your interfaces that host resolution
and other facilities will not work correctly.

Therefore it is recommended that you set up a special `interface` before
any others:

<%= include_example('upgrade-6-09a') %>

FireHOL 2 only:
:   Add a `server ipv6error accept` at the top of the *v6interop*
    interface and again at the top of each router. Read the service
    documentation associated with the version you installed.

    **FireHOL versions 3+ do not require the *ipv6error* service and it will
    be removed from FireHOL 4.**

The remaining ICMPv6 messages should generally not be used in
FireHOL router definitions, since the information they convey should
be kept to the local network.

To allow hosts to communicate with one another over IPv6, network
neighbour solicitation/advertisement messages (which do in IPv6 what
ARP does in IPv4) must be enabled on interfaces.

<%= include_example('upgrade-6-10a') %>

Multicast Listener Discovery should be enabled on any interfaces
taking part on a network which has multicast snooping enabled and
is available from FireHOL versions 2.0.4+ and 3.0.1+.

Depending on the snooping, not having this may prevent neighbour and router
discovery from working. Not everyone likes MLD though, so you may want
to read up on it as many network configurations will work fine without.

<%= include_example('upgrade-6-10b') %>

To allow network route auto-discovery, router
solicitation/advertisement messages must be enabled on interfaces as
a client.

<%= include_example('upgrade-6-11') %>

You can restrict these messages to particular interfaces if you want
to control where your host can see IPv6 routes from.

If your machine will be routing IPv6, it will also need to be able
to send router advertisement messages and Multicast Listener Queries
(the latter for FireHOL versions 2.0.4+ and 3.0.1+).

<%= include_example('upgrade-6-12') %>

## Upgrading Existing Interfaces and Routers

We will show you how to adapt this simple config in a few possible ways:

<%= include_example('upgrade-6-04') %>

-   ### Rules with no address or no IPv6 equivalent

    Any `interface4` or `router4` which should apply to both IPv4 and
    IPv6 with no existing `src` or `dst` should be updated to use the
    keywords without a suffix.

    Other rules which do not have a `src` or `dst` and apply equally to IPv4
    and IPv6 are left unchanged. They will inherit the behaviour of the
    generalised `inerrface` or `router`.

    Rules which apply to IPv4 only or which you only want to apply
    to IPv4 addresses should be explicitly marked if they were not
    already.

    <%= include_example('upgrade-6-05', "    ") %>

    It is also possible to add new rules which only apply to IPv6.

-   ### Rules which an IPv6 address can be added to

    If you do have want to specify an IPv6 address for a particular rule,
    to match an existing IPv4 address, generalise the `client` or `server`
    keyword and specify the addresses explicitly with
    `src4`/`src6` and `dst4`/`dst6` e.g.:

    <%= include_example('upgrade-6-06', "    ") %>

    The FireHOL variables such as \$UNROUTABLE\_IPS will work
    automatically in both contexts, so you can still write:

    <%= include_example('upgrade-6-07', "    ") %>

    If you want to combine this with your own IPs or ranges, you will
    need to be explicit, like this:

    <%= include_example('upgrade-6-09', "    ") %>

    since only the special FireHOL variables automatically switch for IPv4/6.

-   ### Specific IPv4/IPv6 services

    Some services only make sense as IPv4 or IPv6 and are automatically
    switched to that mode. They cannot be included in blocks of rules
    specified to the opposite mode.

    IPv4 only: <%= html_to('dhcp','/keyword/service/dhcp') %> and
    <%= html_to('timestamp','/keyword/service/timestamp') %>.

    IPv6 only: <%= html_to('dhcpv6','/keyword/service/dhcpv6') %>, <%=
    html_to('ipv6neigh','/keyword/service/ipv6neigh') %>, <%=
    html_to('ipv6mld','/keyword/service/ipv6mld') %>, and <%=
    html_to('ipv6router','/keyword/service/ipv6router') %>.
