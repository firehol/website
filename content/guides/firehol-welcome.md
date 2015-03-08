---
title: FireHOL Welcome Guide
submenu: documentation
---

# FireHOL Welcome Guide

Welcome to FireHOL!

We hope you will enjoy running firewalls with FireHOL, as much as we do.

This guide will give a high level overview of FireHOL. It will help you 
understand how it works, how to use it, what can be done with it and how.

This is not a manual. It will not give you all the possible options available. 
It will not explain all details. The purpose of this document is just to give a 
quick start guide.

## Where is the configuration?

Everything related to FireHOL is placed at `/etc/firehol/`

The main configuration file is `firehol.conf`. Everything about the firewall is 
there.

There are several defaults about a FireHOL firewall. We have chosen them so 
that the firewall will be best suited for general use. If you need the change 
these defaults, edit `firehol-defaults.conf`. There are many comments in this 
file, for every option available.

All of the settings available in `firehol-defaults.conf` may also be placed at 
the top of `firehol.conf` (which has higher precedence over 
`firehol-defaults.conf`). 

`firehol.conf` is a shell script. As such, you can write in it anything you 
normally you write on a terminal. You can also use variables, conditional 
statements, loops, etc.

We encourage you to make heavy use of **variables**. Try to use variables for 
assigning names to everything, so that the configuration will be meaningful. 
After all, what FireHOL is all about, is to have a readable, easy to understand 
place for maintaining your  firewall.

## Types of firewalls supported

FireHOL has been designed for **DENY ALL, ALLOW SOME** firewalls. This means 
that if you don't accept something in `firehol.conf`, it will be dropped.

Of course, you may also configure "ALLOW ALL, DENY SOME" firewalls, but we 
strongly suggest to not use firewalls like this.

FireHOL generates firewalls that match **both requests and replies, in both 
directions** of the firewall (in/out and passing in/out).  This is a unique 
feature of FireHOL, among all other firewall tools available.

FireHOL uses the in-kernel connection tracker so that the firewall is 
**stateful**. This means the kernel keeps track of all active connections and 
knows which packets are expected and which are not part of any connection. 
FireHOL, by default, drops all packets considered as INVALID by the connection 
tracker.

FireHOL logs all packets indirectly dropped (i.e. not dropped by a statement 
you specifically requested to drop traffic), so that if something does not 
work, you can check your kernel logs to find out which packet dropped and why 
(yes, FireHOL also logs **why**, or better, **where** in the config).


## IPv4 and IPv6

By default FireHOL will attempt to setup all rules for both IPv4 and IPv6.

You can disable IPv4 or IPv6 by editing `firehol-defaults.conf` and setting 
`ENABLE_IPV4=0` or `ENABLE_IPV6=0`. Of course either of the two will be 
automatically disabled if not available on your machine.

Alternatively, you can prefix any statement with `ipv4` or `ipv6` to have that 
statement applied only in IPv4 or IPv6 respectively, like this: `interface` 
should become `ipv4 interface` or `ipv6 interface`. For interfaces and routers, 
`server` and `client` statements inherit the IP version of the `interface` or 
`router` they appear in.


## The Flow

**The place of all statements in the configuration file is important!**

You should assume there is **a flow** that packets traverse, from the top of 
the configuration file, to the bottom.

iptables runs in layers (it has tables like mangle, nat, filter, and within 
each table it has chains, like PREROUTING, INPUT, FORWARD, OUTPUT, 
POSTROUTING). For the **same kind of statements** though, FireHOL adds them at 
the proper place, **in the same order they appear in `firehol.conf`**. So, even 
if different statements may never interact with each other, statements of the 
same kind do interact and their order is important.

The flow is also important, since once a statement matches the packet, the next 
statement of the same kind will most probably not (there are exceptions to 
this, but this is the general rule).

For example if you `dnat` traffic from 10.0.0.0/8 and then `dnat` traffic from 
10.0.0.1, only the first statement will match a packet from 10.0.0.1. The 
second will be useless. Similarly, if you define first a catch-all interface 
and then an interface for each of the interfaces your have, only the first, the 
catch-all interface, will get all traffic.

So, **pay attention to the flow, the order of statements**.


## Requests and Replies

In FireHOL, every time you give a statement to match some traffic, you only 
need to focus on the **requests**, i.e. the initial packet sent from a client 
to a server. FireHOL will automatically match the replies.

For `interface` and `router` blocks you define the requests in one direction 
and FireHOL automatically matches requests in the opposite direction. This is 
why there is `server` and `client`. Let's see it:

~~~~ {.firehol}
interface eth0 lan
   server smtp accept
   client http accept
~~~~

`lan` is just a name. It will be used for logging and provide some readability 
on the generated iptables rules.

This `interface` matches requests coming in from `eth0` and requests going out 
to `eth0`. We are not talking about replies. Forget them. Only **requests**.
 
- `server smtp accept` matches requests coming in from `eth0`
- `client http accept` matches requests going out to `eth0`

The same is true for routers too:

~~~~ {.firehol}
router myrouter inface eth0 outface eth1
   server smtp accept
   client http accept
~~~~

`myrouter` is again a name.

This `router` matches requests coming in from `eth0` and going out to `eth1`, 
but also requests coming in from `eth1` and going out to `eth0`.
 
- `server smtp accept` matches requests coming in from `eth0` and going out to 
`eth1`
- `client http accept` matches requests coming in from `eth1` and going out to 
`eth0`

So:

1. focus only on **requests**, forget everything about replies
2. **`interface` and `router` match requests on both directions**


## Services

For filtering packets, FireHOL uses **service definitions**, so that for just 
filtering traffic, you don't need to know or repeat what each service means for 
the firewall.

For example, if you run an http server, you just say `server http accept`, 
while if you run an http client you say `client http accept`.

You should define your own services, like this:

~~~~ {.firehol}
server_myhttp_ports="tcp/80,443"
client_myhttp_ports="default"
~~~~

Then, you can use `server myhttp accept` and `client myhttp accept`.

You can put many ports, even with different protocols:

~~~~ {.firehol}
server_emule_ports="tcp/4662,64397,7037,23213,25286 udp/4672"
client_emule_ports="default"
~~~~

or multiple protocols for all ports:

~~~~ {.firehol}
server_sip_ports="tcp,udp/5060"
client_sip_ports="default"
~~~~

There are also complex services that require a lot more than just a bunch of 
server and client ports. To define such complex services you have to write some 
code, in simple bash scripting. Then you could also use them as above.

## Rules

By default all FireHOL statements will match all the packets that reach them.

For example, if you say `server smtp accept`, then all smtp packets in this 
context will be matched.

You can limit the packets matched by any statement by appending **packet 
matching rules**. These rules are accepted everywhere, and they are exactly the 
same. In FireHOL lingo we call these rules **optional rule parameters**.

The key supported parameters are shown below. Remember, you only use these to 
match the **requests**. FireHOL will automatically take care of the replies.

parameter description
--------- ------------------------------------------------------------------------------------------
inface    match the input interface, the interface the packet was received from clients
outface   match the output interface, the interface the packet will use to leave to reach the server
src       the source IP, i.e. the IP of the client sending the packet
dst       the destination IP, i.e. the IP of the server that will receive the packet
proto     the protocol of the packet (tcp, udp, etc)
sport     the source port, i.e. the port of the client sending the packet
dport     the destination port, i.e. the port of the server that receive the packet
mark      the mark assigned to a packet
uid       the user id of the process sending this packet (for localhost clients)
gid       the group id of the process sending this packet (for localhost clients)

Of course, there are many more parameters supported and you can even give 
custom options you know the underlying iptables system will accept.

Most of these parameters accept **multiple values**:

 - Enclose all values in quotes and separate them with space. Example `inface 
"eth0 eth1 eth2"`.
 - Use just a coma, without any space between them, like this: `inface 
eth0,eth1,eth2`.

Parameters may also be **negated**. To negate a parameter, just put the word 
`not` before its values, like this: `inface not "eth0 eth1 eth2"`.

Keep in mind however, that you cannot give both positive and negative values 
for the same parameter at the same statement. You cannot say `inface eth0 not 
eth1`.


## The building blocks

You can start writing your firewall using an empty `firehol.conf`.

There are 3 sections of statements your will need to add:

1. **helpers** - for setting up NAT, MARKs, etc
2. **interfaces** - for protecting the firewall host
3. **routers** - for protecting other hosts in your LAN(s)

They should appear in this order.

We will discuss each of these in detail below.


## interfaces

**Interfaces protect the firewall itself.**

> `interfaces` have nothing to do with routed traffic. For routed traffic use 
**router** blocks.

Think of the interfaces as **zones**:

- you can define one FireHOL interface for every physical interface you have, or
- you can group many physical interfaces together to one FireHOL interface, or
- you can split one physical interface to many FireHOL interfaces

Group or split based on the services you will add to its interface. Group 
multiple interfaces together to manage them all together, as one. Split one 
interface to have different rules for different subnets in it. 

For example, let's say that you have `eth0` and `eth1` as two physical 
interfaces that you just want to provide smtp service to both. You can say:

~~~~ {.firehol}
interface eth0,eth1 lans
   server smtp accept
~~~~

On the other hand, if you have only `eth0` with clients IPs in the subnet 
10.0.0.0/8 and you want to provide smtp to all, but http only to a few trusted 
clients in subnet 10.0.1.0/24, this is what you can say:

~~~~ {.firehol}
interface eth0 lan
   server smtp accept
   server http accept src 10.0.1.0/24
~~~~

or

~~~~ {.firehol}
interface eth0 trusted src 10.0.1.0/24
   server smtp accept
   server http accept
   
interface eth0 lan
   server smtp accept
~~~~

The above uses the **flow**. The `trusted` interface will only process traffic 
from eth0 and from 10.0.1.0/24. All the other traffic from eth0 will be served 
by the `lan` interface.


### policy
Every interface has a **policy**.

**The policy says what to do with the packets that did not match any `server` 
and `client` statements.**

The default for interfaces is **DROP**, meaning that all packets not 
specifically allowed will be dropped.

You can also use **REJECT** to deny access but prevent timeouts. You should use 
**REJECT** on friendly interfaces, so that your clients will not have timeout 
when attempting something that is not allowed.

You can use **ACCEPT** to allow all traffic. You can use this on your home LAN, 
where you don't need a firewall on this side of the host. Keep in mind though, 
that the connection tracker will be used even in this case. INVALID packets 
(i.e. packets the kernel connection tracker believes they do not participate on 
valid connections), will be dropped (and logged).

You can also use **RETURN**. This make the packets that reach the end of an 
interface, to continue to the next interface. So the last example above, can be 
written as:

~~~~ {.firehol}
interface eth0 trusted src 10.0.1.0/24
   policy RETURN
   server http accept
   
interface eth0 lan
   server smtp accept
~~~~

In this example, the `trusted` interface will get all the packets from eth0 and 
subnet 10.0.1.0/24, it will accept the http traffic, but will allow all the 
packets except http to flow to the next interface, so that even the subnet 
10.0.1.0/24 will get access to smtp. If a packet is not matched at any 
interface, it will be dropped at the end of the firewall.

You can also define your own actions using the `action` helper. Using your own 
actions you can setup traps or take different actions for different traffic.

### Examples

So, the most common setup for your home router would be:

~~~~ {.firehol}
# our LAN network
interface eth0 lan
   policy accept

# all other interfaces
interface any internet
   client all accept
~~~~

## routers

**Routers are used to filter traffic passing through the firewall host.**

Routers do not interfere with interfaces. They are two different things. You 
can group and split routers in a completely different fashion than interfaces.

Routers can be very confusing at first. Let's see why:

The most basic router block is this:

~~~~ {.firehol}
router alltraffic
~~~~

`alltraffic` is just a name. This will match all the routed traffic, from any 
interface to any other. Can we add `server` and `client` statements to it?

**Well, we can, but we shouldn't!**

The best use of a router is to first pick a combination of physical interfaces. 
The interface the traffic will come in and the interface it will go out. Of 
course, we only care about the requests (FireHOL will handle the replies) in 
both directions.

To pick the input and the output interfaces (`inface` and `outface` in FireHOL 
lingo) we just need to decide **which side we need to protect**.

Let's say that we have internet on `ppp+` (the `+` is a wildcard, meaning any 
string, so `ppp0,ppp1,...,pppother,...`) and local hosts on `eth0`. We will 
want to say `server x accept` for servers running on our local hosts and 
`client x accept` for clients running on local hosts.

To do this, we design a router that **matches the packets from which we need to 
be protected**, i.e. **requests going to the hosts we want to protect**, like 
this:

~~~~ {.firehol}
# packets coming from internet towards our LAN
router internet2lan inface ppp+ outface eth0
   client all accept
   server smtp accept dst 10.0.0.2
~~~~

It is important to do it this way, because if you say `router lan2internet 
inface eth0 outface ppp+`, things will be very confusing. It will be very hard 
for you to describe your smtp server running on 10.0.0.2.

Of course, there are cases where both sides need to be protected. For example, 
when we have a LAN on `eth0` with client PCs and a LAN on `eth1` with servers. 
Both should be protected.

The rule remains: design a router that matches the packets from which you need 
to be protected, i.e. **the requests going to the hosts you want to protect**. 
In this case the key hosts to be protected are your servers, since you don't 
trust the clients entirely.

Let's see it:

~~~~ {.firehol}
router clients2servers inface eth0 outface eth1
   server smtp accept dst 10.0.0.2
~~~~

With just the above, only smtp traffic between clients on eth0 and the smtp 
server 10.0.0.2 on eth1 will be allowed. Both LANs are totally protected from 
each other.

What if we also run an http server on the clients LAN at IP 10.1.0.32 that we 
need to access it from the servers LAN?

You can add a client statement like this:

~~~~ {.firehol}
router clients2servers inface eth0 outface eth1
   server smtp accept dst 10.0.0.2
   client http accept dst 10.1.0.32
~~~~

But in this case, this seems to be confusing again. A better solution would be 
to just add another router in the opposite direction. The default policy on all 
routers is **RETURN**, so that packets are not dropped by default; they 
continue to be matched against the other routers available. Let's see it:

~~~~ {.firehol}
router clients2servers inface eth0 outface eth1
   server smtp accept dst 10.0.0.2

router servers2clients inface eth1 outface eth0
   server http accept dst 10.1.0.32
~~~~

This seems more appropriate.

Try to pay some attention on how you express your routers. If you do it right, 
things will be very easy. If the way you have expressed a router makes it 
difficult for you to add server and client statements, you are doing it wrong.

You may find examples using `route smtp accept`. `route` is a synonym for 
`server` and can only be used in routers.

Of course you can group or split physical interfaces in routers too.

To group multiple interfaces use something like this:

~~~~ {.firehol}
router lan2lan inface eth0,eth1 outface eth2,eth3
~~~~

To split an interface, limit it by `src` or `dst` (use `src` to split `inface`, 
and `dst` to split `outface`), like this:

~~~~ {.firehol}
router router1 inface eth0 src 10.0.1.0/24 outface eth1
   server ...
   
router router2 inface eth0 src 10.0.2.0/24 outface eth1
   server ...
~~~~

### policy

The default policy for routers is **RETURN**. This makes routed packets be 
checked against all routers defined, and dropped at the end of the firewall if 
none matches them.

There is a reason for this default policy. Check this example:

~~~~ {.firehol}

router r1 inface eth0 outface eth1
   server smtp accept

router r2 inface eth1 outface eth0
   server http accept
~~~~

In this example, if the default policy was not RETURN, packets from eth1 to 
eth0 would never reach router r2. FireHOL would expect `client` statements for 
this kind of traffic in router r1 and since there are no such statements 
defined, this traffic would have been dropped at the end of router r1.


## helpers

FireHOL supports many helpers for almost anything that can be done at the 
firewall level (NAT, MARKs, transparent proxies, traps, knocks, load balancers, 
SYNPROXY, etc).

However, the key feature helpers provide is NAT. 

There are two kinds of NAT supported:

- **source NAT**, to change the source IP of packets
- **destination NAT**, to divert the packets to another server

> Keep in mind that in FireHOL, helpers do not interfere with packet filtering. 
Packet filtering should be expressed with `interface` and `router` blocks, 
using `server` and `client` statements.


### source NAT

The main use of source NAT is when we route packets for our LANs to the 
internet. We masquerade the source IP of the packets we send so that the 
replies will come back to us.

There are two helpers that support this in FireHOL:

- `masquerade` which dynamically checks the IP the interface is using to find 
the IP that should be used
- `snat` which statically assigns an IP we already know (which is more 
efficient)

To use `masquerade` just add this at the top of `firehol.conf`:

~~~~ {.firehol}
masquerade ppp+
~~~~

Of course, change `ppp+` to your internet interface.

To use `snat` add something like this:

~~~~ {.firehol}
snat to 1.2.3.4 outface ppp+
~~~~

Both `masquerade` and `snat` support the **optional rule parameters** for fine 
control.

### destination NAT

The main use of destination NAT is to divert packets coming to or through the 
firewall host, to somewhere else.

There are two helpers for destination NAT:

- `dnat` to send the traffic to another host
- `redirect` to redirect the traffic to a process on the firewall

To use `dnat`, add at the top of `firehol.conf` something like this:

~~~~ {.firehol}
dnat to 10.0.0.2 inface ppp+ proto tcp dport 80
~~~~

The above, will send all requests that are received via `ppp+` for tcp/80 to 
server 10.0.0.2. Remember there must be a router definition with `server http 
accept dst 10.0.0.2`, otherwise the diversion will happen, but the packet will 
be dropped at packet filtering.

To use `redirect`, add at the top of `firehol.conf` something like this:

~~~~ {.firehol}
redirect to 80 inface ppp+ proto tcp dport 81
~~~~

The above will send to local port 80 all traffic at is received via `ppp+` for 
port tcp/81. For this you will need `server http accept` at an interface.

These commands use the **optional rule parameters**, so it is possible to 
modify traffic based on criteria of your choosing (i.e. original destination IP 
address, if you have multiple public IPs).

## NAT and filtering

When you NAT, you actually overwrite something on the packet. You change its 
source or destination IP, its source or destination port, or all of them.

You should remember that for packet filtering to work, you should match with 
`interface`, `router`, `server` and `client` what **really the traffic is**.

**really** means how the firewall host sees the traffic.

For example, for destination NAT (`dnat` or `redirect`), the actual filtering 
flow is after the NAT.  For example:

~~~~ {.firehol}
dnat to 10.0.0.2 dst 1.2.3.4
~~~~

Where does the packet **really** go? It was sent to 1.2.3.4, but we diverted it 
to 10.0.0.2, so it will actually go to 10.0.0.2. This is how to match it in 
packet filtering.

Things can be a little more complicated when changing ports. For example:

~~~~ {.firehol}
redirect to 81 dst 1.2.3.4 inface ppp+ proto tcp dport 80
~~~~

This sends to port 81 what we receive via ppp+ on tcp/80 for host 1.2.3.4.
Where does the packet **really** go? To port tcp/81 on localhost. How do we 
match tcp/81? There is no such service already defined. So we need to add it:

~~~~ {.firehol}
server_http81_ports="tcp/81"
client_http81_ports="default"

redirect to 81 dst 1.2.3.4 inface ppp+ proto tcp dport 80

interface ppp+ world
    server http81 accept
~~~~

On the other hand, source NAT can be ignored. It happens after packet filtering 
and it cannot change the actual flow of the packet.

## Keep it small and readable

To save time and keep the configuration small, you can put many things together 
in one line.

For example, let's say you have this:

~~~~ {.firehol}
interface ppp+ world
    client  all accept
 
    server  dns     accept
 
    server  ping    accept
 
    server  http    accept
    server  https   accept
 
    server  ntp     accept
 
    server  ssh     accept
 
    server  smtp    accept
    server  smtps   accept
    server  pop3    accept
    server  pop3s   accept
    server  imap    accept
    server  imaps   accept
~~~~

You can write it like this:

~~~~ {.firehol}
public_services="dns ping http https ntp ssh smtp smtps pop3 pop3s imap imaps"

interface ppp+ world
    client all accept
    server "${public_services}" accept
~~~~

Similarly if you want to `dnat` multiple ports to a server on your LAN, you can 
group them together too. For example let's say that you have this:

~~~~ {.firehol}
wan="ppp+"
WIN7_JP_P2P="192.168.0.50"

ipv4 dnat to "${WIN7_JP_P2P}" inface "${wan}" proto tcp dport 4662
ipv4 dnat to "${WIN7_JP_P2P}" inface "${wan}" proto udp dport 4672
ipv4 dnat to "${WIN7_JP_P2P}" inface "${wan}" proto tcp dport 64397
ipv4 dnat to "${WIN7_JP_P2P}" inface "${wan}" proto tcp dport 7037
ipv4 dnat to "${WIN7_JP_P2P}" inface "${wan}" proto tcp dport 23213
ipv4 dnat to "${WIN7_JP_P2P}" inface "${wan}" proto tcp dport 25286

router myrouter ...
    ipv4 client custom p2p_emule   "tcp/4662 udp/4672" default accept  dst "${WIN7_JP_P2P}"
    ipv4 client custom p2p_pd       tcp/64397          default accept  dst "${WIN7_JP_P2P}"
    ipv4 client custom p2p_shareex2 tcp/7037           default accept  dst "${WIN7_JP_P2P}"
    ipv4 client custom p2p_winny2   tcp/23213          default accept  dst "${WIN7_JP_P2P}"
    ipv4 client custom p2p_winny2p  tcp/25286          default accept  dst "${WIN7_JP_P2P}"
~~~~

You can write this as:

~~~~ {.firehol}
wan="ppp+"
WIN7_JP_P2P="192.168.0.50"

# define the service
server_myemule_ports="tcp/4662,64397,7037,23213,25286 udp/4672"
client_myemule_ports="default"

# do the nat
for x in ${server_myemule_ports} # without quotes
do
    ipv4 dnat to "${WIN7_JP_P2P}" inface "${wan}" proto ${x/\/*//} dport 
${x/*\//}
done

# accept it
router myrouter ...
    ipv4 server myemule accept dst "${WIN7_JP_P2P}"
~~~~

The idea is to keep it small and readable. To give names for everything so that 
you will not have in front of you lists of ports, but names that mean something.

## The LOG

FireHOL has been designed to log packets indirectly dropped.

The internet is full of noise, random packets and some of them will eventually 
reach you. This means you will always have some packets logged.

We suggest to install **ulogd** and set `FIREHOL_LOG_MODE="NFLOG"` at the top 
of `firehol.conf` or at `firehol-defaults.conf`.

This will totally clear your `dmesg` and kernel logs.

With ulogd, all packets are logged to a dedicated file (check your 
`/etc/ulogd.conf`, usually NFLOG goes to a file in `/var/log/ulogd` named 
something like `syslogemu.log` or `ulogd_syslogemu.log`).



## Complete Example

For your home router you will need something like this:

~~~~ {.firehol}
# the device that connects you to the internet
world="ppp+"

# the device that connects you to your home PCs
home="eth0"

# have outgoing traffic use the public IP
ipv4 masquerade "${world}"

# fix tcp mss for ppp devices
tcpmss auto "${world}"

# our LAN network
interface "${home}" home
   policy accept

# our internet interface
interface "${world}" world
   protection bad-packets
   client all accept

# internet traffic for out LAN PCs
router world2home inface "${world}" outface "${home}"
   protection bad-packets
   client all accept
~~~~

Using the above configuration you will be able to use any service on the 
internet, but as far as the rest of the world is concerned, you do not exist. 
They will not be able to ping you or use anything on your firewall or home 
computers.

## Applying the firewall

To apply a new firewall, run:

~~~~ {.bash}
firehol try
~~~~

`try` is a special feature that will help you recover if you accidentally mess 
the firewall and you get locked out. It will apply the firewall and wait 30 
seconds for you to type `commit`. If you don't type `commit` in 30 seconds, it 
will automatically rollback the firewall, to the state it was before applying 
it.

In version 3 of FireHOL, firewall activation is atomic. This means the new 
firewall is applied at once. The whole of it. We call this feature **fast 
activation**.

## Seeing what FireHOL does

FireHOL has another unique feature. It can show you what it does for each 
statement. Try it. Run on a terminal:

~~~~ {.bash}
firehol explain
~~~~

Then, at the FireHOL prompt, enter these commands:

~~~~ {.firehol}
interface eth0 world
~~~~

then:

~~~~ {.firehol}
server smtp accept
~~~~

FireHOL will generate iptables rules fully commented, for you to review and 
audit what it does.
