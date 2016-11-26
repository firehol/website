ICMPv6 Firewall Recommendations
===============================

Introduction
------------

[RFC 4890](http://tools.ietf.org/html/rfc4890) is entitled
"Recommendations for Filtering ICMPv6 Messages in Firewalls".

The recommendations pertain to firewalling at router level, not
necessarily hosts or bridges (which may need to treat some packets
differently, e.g. NS/NA and RS/RA).

The sections below were extracted from the example implementation; each
one describes how the recommendation can be achieved with FireHOL.

It is assumed that a policy of reject or deny is in place. If that is
not the case then some packet types need dropping explicitly to meet the
recommendations.

Allow outbound echo requests from prefixes which belong to the site
-------------------------------------------------------------------

The [router](/keyword/firehol/router) command should be used with an
appropriate [src](/keyword/firehol/src) rule parameter.

Allow inbound echo requests towards only predetermined hosts
------------------------------------------------------------

The [ping service](/keyword/service/ping) should be used in combination
with an appropriate [dst](/keyword/firehol/dst) rule parameter.

Allow incoming and outgoing echo reply messages only for existing sessions
--------------------------------------------------------------------------

This is handled automatically by the [ping service](/keyword/service/ping).

Deny icmps to/from link local addresses
---------------------------------------

The [router](/keyword/firehol/router) command should be used with an
appropriate [src](/keyword/firehol/src)
and [dst](/keyword/firehol/dst) rule parameter. For example:

~~~~ {.firehol}
src not "${UNROUTABLE_IPS}" dst not "${UNROUTABLE_IPS}"
~~~~

Drop echo replies which have a multicast address as a destination
-----------------------------------------------------------------

The [ping service](/keyword/service/ping) can be used with an
appropriate [src](/keyword/firehol/src) rule parameter. For example:

~~~~ {.firehol}
ipv6 route ping src not "${MULTICAST6_IPS}"
~~~~

will prevent incoming echo-requests from multicast IPs and replies to
them.

Allow incoming destination unreachable messages only for existing sessions
--------------------------------------------------------------------------

This is handled automatically by FireHOL 3+.

Allow outgoing destination unreachable messages
-----------------------------------------------

The rule(s) suggested by
["allow incoming destination unreachable messages only for existing sessions"](#allow-incoming-destination-unreachable-messages-only-for-existing-sessions)
will also meet this recommendation.

Allow incoming Packet Too Big messages only for existing sessions
-----------------------------------------------------------------

The rule(s) suggested by
["allow incoming destination unreachable messages only for existing sessions"](#allow-incoming-destination-unreachable-messages-only-for-existing-sessions)
ill also meet this recommendation.

Allow outgoing Packet Too Big messages
--------------------------------------

The rule(s) suggested by
["allow incoming destination unreachable messages only for existing sessions"](#allow-incoming-destination-unreachable-messages-only-for-existing-sessions)
ill also meet this recommendation.

Allow incoming time exceeded code 0 messages only for existing sessions
-----------------------------------------------------------------------

The rule(s) suggested by
["allow incoming destination unreachable messages only for existing sessions"](#allow-incoming-destination-unreachable-messages-only-for-existing-sessions)
ill also meet this recommendation.

Allow incoming time exceeded code 1 messages
--------------------------------------------

The rule(s) suggested by
["allow incoming destination unreachable messages only for existing sessions"](#allow-incoming-destination-unreachable-messages-only-for-existing-sessions)
ill also meet this recommendation.

> **Note**
>
> In the example RFC script, non-established/related messages are
> allowed through for this type.
>
> It is not clear why since code 0 and not code 1 messages are listed as
> part of the establishment of communications. Code 1 messages are
> listed as less essential for propagation over the network.
>
> The behaviour implemented here is as per destination unreachable
> messages, so the same as the incoming time exceeded code 0 messages
> example.

Allow outgoing time exceeded code 0 messages
--------------------------------------------

The rule(s) suggested by
["allow incoming destination unreachable messages only for existing sessions"](#allow-incoming-destination-unreachable-messages-only-for-existing-sessions)
ill also meet this recommendation.

Allow outgoing time exceeded code 1 messages
--------------------------------------------

The rule(s) suggested by
["allow incoming destination unreachable messages only for existing sessions"](#allow-incoming-destination-unreachable-messages-only-for-existing-sessions)
ill also meet this recommendation.

Allow incoming parameter problem code 1 and 2 messages for an existing session
------------------------------------------------------------------------------

The rule(s) suggested by
["allow incoming destination unreachable messages only for existing sessions"](#allow-incoming-destination-unreachable-messages-only-for-existing-sessions)
ill also meet this recommendation.

Allow outgoing parameter problem code 1 and code 2 messages
-----------------------------------------------------------

The rule(s) suggested by
["allow incoming destination unreachable messages only for existing sessions"](#allow-incoming-destination-unreachable-messages-only-for-existing-sessions)
ill also meet this recommendation.

Allow incoming and outgoing parameter problem code 0 messages
-------------------------------------------------------------

From the RFC it is not really necessary to allow these messages. FireHOL
handles this automatically (by dropping them) unless you create a rule
to explicitly allow the packets using the icmpv6 type bad-header.

Drop NS/NA messages both incoming and outgoing
----------------------------------------------

FireHOL handles this automatically unless you set up an explicit route
for the packets.

> **Note**
>
> Hosts and bridges need to allow these messages.
> See [ipv6neigh](/keyword/service/ipv6neigh).

Drop RS/RA messages both incoming and outgoing
----------------------------------------------

FireHOL handles this automatically unless you set up an explicit route
for the packets.

> **Note**
>
> Hosts and bridges need to allow these messages.
> See [ipv6router](/keyword/service/ipv6router).

Drop Redirect messages both incoming and outgoing
-------------------------------------------------

FireHOL handles this automatically unless you set up an explicit route
for the packets.

> **Note**
>
> At some point FireHOL may have a helper command added to simplify
> allowing these messages on a host/bridge. Meantime this is an example
> of the relevant ip6tables command:
>
>     ip6tables -A icmpv6-filter -p icmpv6 --icmpv6-type redirect -j DROP

Drop incoming and outgoing Multicast Listener queries (MLDv1 and MLDv2)
-----------------------------------------------------------------------

FireHOL handles this automatically unless you set up an explicit route
for the packets.

> **Note**
>
> At some point FireHOL may have a helper command added to simplify
> allowing these messages on a host/bridge. Meantime this is an example
> of the relevant ip6tables command:
>
>     ip6tables -A icmpv6-filter -p icmpv6 --icmpv6-type 130 -j DROP

Drop incoming and outgoing Multicast Listener reports (MLDv1)
-------------------------------------------------------------

FireHOL handles this automatically unless you create a rule to
explicitly allow the packets.

> **Note**
>
> At some point FireHOL may have a helper command added to simplify
> allowing these messages on a host/bridge. Meantime this is an example
> of the relevant ip6tables command:
>
>     ip6tables -A icmpv6-filter -p icmpv6 --icmpv6-type 131 -j DROP

Drop incoming and outgoing Multicast Listener Done messages (MLDv1)
-------------------------------------------------------------------

FireHOL handles this automatically unless you create a rule to
explicitly allow the packets.

> **Note**
>
> At some point FireHOL may have a helper command added to simplify
> allowing these messages on a host/bridge. Meantime this is an example
> of the relevant ip6tables command:
>
>     ip6tables -A icmpv6-filter -p icmpv6 --icmpv6-type 132 -j DROP

Drop incoming and outgoing Multicast Listener reports (MLDv2)
-------------------------------------------------------------

FireHOL handles this automatically unless you create a rule to
explicitly allow the packets.

> **Note**
>
> At some point FireHOL may have a helper command added to simplify
> allowing these messages on a host/bridge. Meantime this is an example
> of the relevant ip6tables command:
>
>     ip6tables -A icmpv6-filter -p icmpv6 --icmpv6-type 143 -j DROP

Drop router renumbering messages
--------------------------------

FireHOL handles this automatically unless you create a rule to
explicitly allow the packets.

> **Note**
>
> At some point FireHOL may have a helper command added to simplify
> allowing these messages on a host/bridge. Meantime this is an example
> of the relevant ip6tables command:
>
>     ip6tables -A icmpv6-filter -p icmpv6 --icmpv6-type 138 -j DROP

Drop node information queries (139) and replies (140)
-----------------------------------------------------

FireHOL handles this automatically unless you create a rule to
explicitly allow the packets.

> **Note**
>
> At some point FireHOL may have a helper command added to simplify
> allowing these messages on a host/bridge. Meantime this is an example
> of the relevant ip6tables command:
>
>     ip6tables -A icmpv6-filter -p icmpv6 --icmpv6-type 139 -j DROP
>     ip6tables -A icmpv6-filter -p icmpv6 --icmpv6-type 140 -j DROP

If there are mobile ipv6 home agents present on the trusted side allow
----------------------------------------------------------------------

At some point FireHOL may have a helper command added to simplify this
setup. Meantime this is an example of the relevant ip6tables commands
from the RFC script:

    #incoming Home Agent address discovery request
    ip6tables -A icmpv6-filter -p icmpv6 -d $inner_prefix \
         --icmpv6-type 144 -j ACCEPT
    #outgoing Home Agent address discovery reply
    ip6tables -A icmpv6-filter -p icmpv6 -s $inner_prefix \
         --icmpv6-type 145 -j ACCEPT
    #incoming Mobile prefix solicitation
    ip6tables -A icmpv6-filter -p icmpv6 -d $inner_prefix \
         --icmpv6-type 146 -j ACCEPT
    #outgoing Mobile prefix advertisement
    ip6tables -A icmpv6-filter -p icmpv6 -s $inner_prefix \
         --icmpv6-type 147 -j ACCEPT

If there are roaming mobile nodes present on the trusted side allow
-------------------------------------------------------------------

At some point FireHOL may have a helper command added to simplify this
setup. Meantime this is an example of the relevant ip6tables commands
from the RFC script:

    #outgoing Home Agent address discovery request
    ip6tables -A icmpv6-filter -p icmpv6 -s $inner_prefix \
         --icmpv6-type 144 -j ACCEPT
    #incoming Home Agent address discovery reply
    ip6tables -A icmpv6-filter -p icmpv6 -d $inner_prefix \
         --icmpv6-type 145 -j ACCEPT
    #outgoing Mobile prefix solicitation
    ip6tables -A icmpv6-filter -p icmpv6 -s $inner_prefix \
         --icmpv6-type 146 -j ACCEPT
    #incoming Mobile prefix advertisement
    ip6tables -A icmpv6-filter -p icmpv6 -d $inner_prefix \
         --icmpv6-type 147 -j ACCEPT

Drop everything else
--------------------

FireHOL handles this automatically unless you create a rule to
explicitly allow the packets.
