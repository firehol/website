---
title: FireQOS New User Tutorial
submenu: documentation
---

FireQOS New User Tutorial
=========================

At the end of the tutorial you will have perfect traffic control on any
interface you choose. You can also use this guide to set up FireQOS for
just monitoring the traffic: without any traffic shaping at all.

[1. Pick an interface](#pick-an-interface)

-   [Controlling Incoming Traffic](#controlling-incoming-traffic)
-   [DSL based links](#dsl-based-links)

[2. Adding Classes](#adding-classes)

[3. Classifying Traffic](#classifying-traffic)

-   [Classifying normal internet surfing
    traffic](#classifying-normal-internet-surfing-traffic)
-   [Classifying interactive traffic](#classifying-interactive-traffic)
-   [Classifying VoIP, VPNs and Facetime
    traffic](#classifying-voip-vpns-and-facetime-traffic)
-   [Classifying torrents](#classifying-torrents)

[4. Traffic Shaping](#traffic-shaping)

[Final Notes](#final-notes)

-   [Traffic Control on Very Busy
    Servers](#traffic-control-on-very-busy-servers)

1. Pick an interface
--------------------

The first step is to pick an interface to setup QoS. You can choose any
interface you like. Even one with real traffic in it. We will not
disrupt it.

**IMPORTANT**

It is required from you to know the speed of the interface. It does not
matter if it is symmetric or asymmetric. The only thing that can go
wrong at this point, is to drain the interface by giving a very low
speed for it at FireQOS. If you do set the right speed, traffic will not
be disrupted at all. If you set it too low and there is a lot of
traffic, you may end up locked out of your systems. **So please be
careful when choosing the speed**.

Now edit `/etc/firehol/fireqos.conf`{.filename} and add these:

<%= include_example("qos-tutorial-01") %>

`DEVICE` is the interface you will be using. `INPUT_SPEED` is the
download speed of your interface. `OUTPUT_SPEED` is the upload speed of
your interface.

Note that there is no space between the number and the unit. You can
also omit the unit if you use kbits/second. This unit (kbits/second) is
the default for FireQOS speeds.

Keep in mind that the FireQOS configuration file is a normal shell
script. You can write anything you normally write in shell scripts,
including variables, conditional statements, loops, call external
commands, etc.

Now, lets add the interface definitions. Unlike FireHOL, FireQOS
requires from you to define INPUT and OUTPUT of interfaces separately.
So for just one interface, you will have to define two interfaces in
FireQOS: one `input` (traffic coming in) and one `output` (traffic going
out). Each of these can be configured in a completely independent way.

<%= include_example("qos-tutorial-02") %>

`world-in` and `world-out` are just names. Use anything you like, but
make sure they do not have a space in them.

`input` and `output` are FireQOS keywords that define the direction of
traffic you want to control. This requires a bit more explanation:

### Controlling Incoming Traffic

FireQOS can set up classful traffic shaping in both directions, both
INPUT and OUTPUT. We all know that classful QoS can only be applied to
the output of an interface. How does FireQOS apply classful traffic
shaping on the INPUT of an interface?

FireQOS utilises Linux kernel magic. Linux kernels have a special device
called
[IFB](http://www.linuxfoundation.org/collaborate/workgroups/networking/ifb).
These devices can get incoming traffic from a real interface and provide
you with the ability to shape this traffic on their virtual output. It
sounds complicated. It is not. IFB devices do not interfere with routing
or firewalling. FireQOS handles everything about IFB devices for you.
They will be there, but you can ignore them. Of course, you kernel has
to have support for IFB devices (either build-in or module is ok).

When shaping incoming traffic, FireQOS will shape the incoming packets
much like it does for outgoing traffic. However there is a little
difference. When your link is 100% used in the inbound direction (100%
download), new incoming sockets will briefly fill the queues of the
previous router in you path. This cannot be avoided. Once a few of these
packets arrive at you, Linux kernel will recalculate the classes and
shape the traffic accordingly. During this process the previous router
in your path will be de-queued.

To minimise the time needed to dequeue the previous router, you should
not use all the incoming bandwidth. If you give 90% of the bandwidth as
the `rate` at the `input` interface definition, there will be enough
bandwidth for your machine to learn quickly there is new traffic coming
in and shape the traffic faster to the desired rate, for the parent
router to be dequeued quickly.

### DSL based links

Another important parameter is the type of internet link you use. You
may be connected to your router or modem via Ethernet. We don't care
about this. What we are interested is the type of link your modem or
router has with its remote end. If you are lucky enough to have an
Ethernet internet link, everything is fine. You don't have to do
anything more. But if your link is ATM based (like DSL), we need some
additional information:

ATM (and therefore DSL) is cell based. This means that in order for your
packets to be transmitted to the other side, they are encapsulated in
ATM cells. This encapsulation adds some overheads. If you are
transmitting very small packets (like VoIP does), the overheads can grow
significantly as a percentage of the real traffic transmitted.

**If you use an ATM based internet connection (like DSL), without proper
overheads calculation, there is no way to get traffic shaping right.**

Of course, if you don't care about shaping at the moment and you just
want to monitor the traffic passing through, you can skip this section
and proceed to the next step.

FireQOS can configure the kernel for proper ATM overheads calculation.
To do it though, it needs the following information:

1.  The protocol used. This can either be `PPPoE`, `PPPoA`, `IPoA`
    or `Bridged`. Note that RFC 1483 Bridging should be PPPoE. `Bridged`
    should only be used when neither PPPoE, PPPoA nor IPoA are used.
2.  The ATM encapsulation used. This can either be `VC/Mux` or
    `LLC/SNAP`
3.  The type of connection to your router / modem. This can either be
    `local` meaning that you run PPPoE on your Linux (it does not matter
    if this is an Ethernet modem - if you run PPPoE on your Linux, you
    should use `local`), or `remote` meaning that you have a Ethernet
    router has handles everything about your internet connection.
4.  If you selected `remote`, it would be very helpful if you could also
    find the MTU.

It is now time to login to your modem / router and find the above
information.

Mine for example, is PPPoE, LLC and I run PPPoE on my Linux box,
therefore `local`. Since it is `local` I don't have to find the MTU.
FireQOS will detect it.

Here is an updated version of the config, updated with the DSL
information:

<%= include_example("qos-tutorial-03") %>

I used the variable `LINKTYPE`, so that for the rest of the tutorial you
can just copy-paste the interfaces. Put your link type in the `LINKTYPE`
variable.

The second parameter of `adsl` can either be `pppoe-llc`, `pppoe-vcmux`,
`pppoa-llc`, `pppoa-vcmux`, `ipoa-llc`, `ipoa-vcmux`, `bridged-llc`,
`bridged-vcmux`.

If you also found the MTU, just append `mtu XXXX` to the LINKTYPE
variable.

* * * * *

Now we are ready for our first run. Without giving anything else, lets
run it with `sudo fireqos start`:

~~~~ {.programoutput}
# sudo fireqos start
FireQOS v1.0 DEVELOPMENT
(C) 2013 Costa Tsaousis, GPL

: interface dsl0 world-in input rate 12000kbit adsl local pppoe-llc (ifb1, MTU 1492, quantum 1492)
:       class default (1:5000, prio 0)

: interface dsl0 world-out output rate 800kbit adsl local pppoe-llc (dsl0, MTU 1492, quantum 1492)
:       class default (1:5000, prio 0)


All Done!. Enjoy...
bye...
~~~~

Applied! As you can see, FireQOS found the MTU. It also added by itself
the `default` class. The `default` class is the one that gets all
traffic we leave unclassified. We will discuss classification in detail
later.

Let's now see the traffic we are sending with
`sudo fireqos status world-out`. We expect to see just one class, the
`default`, having all the traffic we are sending out.

~~~~ {.programoutput}
# sudo fireqos status world-out
Password:
FireQOS v1.0 DEVELOPMENT
(C) 2013 Costa Tsaousis, GPL

world-out: dsl0 output => dsl0, type: adsl, overhead: 40
Rate: 800Kbit/s, min: 12Kbit/s
Values in Kbit/s

 CLASS defaul
CLASSI 1:5000
PRIORI      0
COMMIT     12
   MAX    800


   world-out (dsl0 output => dsl0) - values in Kbit/s
 TOTAL defaul
   812    812
   802    802
   811    811
   795    795
   817    817
   797    797
   808    808
   803    803
   811    811
   807    807
   795    795
   817    817
~~~~

Press Control-C to stop it.

Perfect! My interface is transmitting at full rate (yes, I have a
torrent client running, so the link is always 100% used in the outgoing
direction).

You may notice that a few lines exceed the 800kbit rate I specified.
Don't worry about that. The Linux kernel exposes current class rate
information once every 10 seconds. Instead of displaying this info,
FireQOS' status mode calculates the class rate every second, based on
the bytes sent or received. I have done the most to make it precisely
wait 1000ms minus the time it takes for a line to be calculated and
printed, but shell scripting is not that accurate. The result is that,
depending on your machine speed and load, you may see little variations.
They are only a presentation problem. Your traffic is shaped by the
kernel at exactly the speed you specified.

The output you will get from FireQOS status mode is colorful. Yellow
numbers indicate that the class has some backlog of packets (at least
one packet). A red background indicates that the class dropped one or
more packets. All these are recalculated for every row printed.

You can also check the incoming direction by running
`sudo fireqos status world-in`.

At this point we have just the proper interfaces set up, without any
shaping, without any traffic classification. This is pretty much the
same with no traffic control applied. In reality though we are a little
bit better - FireQOS uses `fq_codel` (if available, `sfq` otherwise) by
default for all classes, including the `default`. Since all traffic ends
up in the `default` class, this qdisc tries to be balance the bandwidth
between the sockets, so even with this minimal configuration, our
traffic is distributed with some fairness among all sockets. `fq_codel`
is even smarter to favor new sockets over the older ones so that surfing
for example will be snappier even when big downloads are in place.

2. Adding Classes
-----------------

Using classes you group traffic together. Once you have grouped all
traffic in classes, you can then define how the classes relate to each
other. Traffic control is applied at the class level.

FireQOS is very flexible in this area. You can define classes and groups
of classes in any manner you like. You can have classes, groups of
classes, groups of groups of classes, etc, with virtually no limit. The
only limitation FireQOS has is that each interface can get up to 5.000
classes.

To decide what classes to add, you have to somehow identify your needs.
In my case for example, for my home ADSL connection:

1.  I have torrents running all the time. I want them to use all the
    bandwidth available, but I don't want them to be a problem for
    anything else. When anything else is running on the link, I need
    them to use only the bandwidth not needed, even if they have to be
    shaped to almost zero.
2.  I have normal internet surfing needs. I want surfing to be preferred
    over torrents, so that regular web surfing or web downloads be as
    speedy as possible.
3.  I have a few VPNs. These are my personal VPNs, meaning that most of
    the time are idle. I would like VPNs to be given all the bandwidth
    they need, even if normal web surfing is throttled.
4.  I use Apple's Facetime from time to time. While I am having a
    Facetime session, I would like to have the maximum possible
    bandwidth, so that video quality is the best.
5.  I would like my SSH sessions to be preferred over all the above, so
    if I run an SSH session I would like it to be as interactive as
    possible, like nothing else is running on the link.
6.  I run an asterisk with VoIP. My family is very sensitive about phone
    call quality. So I need my phones to be perfect all the time.

I am going to add one class for each of the above and I'll do it in
reverse order: **the most important class at the top**.

I want them in order of importance for two reasons:

​a. Later we are going to classify traffic, i.e. assign packets to
classes. For this classification we'll have to find the exact packets we
need, out of the thousands of packets passing through. So, to make our
lives easier, I prefer to put the important classes at the top, hopping
that it will be easier to match the important stuff. b. FireQOS gives a
priority to each class, in the order they appear in the configuration.
So, we need the most important class to get the highest priority. We
will see later what this priority does.

So, here are the classes in order of importance:

<%= include_example("qos-tutorial-04") %>

Lets apply this. Again, using this config we will not disrupt the
traffic. We expect to see all classes configured, but all the traffic
will again be running through the default class.

~~~~ {.programoutput}
# sudo fireqos start
FireQOS v1.0 DEVELOPMENT
(C) 2013 Costa Tsaousis, GPL

: interface dsl0 world-in input rate 12000kbit adsl local pppoe-llc (fireqos-ifb1, MTU 1492, quantum 1492)
:       class voip (1:11, prio 0)
:       class interactive (1:12, prio 1)
:       class facetime (1:13, prio 2)
:       class vpns (1:14, prio 3)
:       class surfing (1:15, prio 4)
:       class torrents (1:16, prio 5)
:       class default (1:5000, prio 6)

: interface dsl0 world-out output rate 800kbit adsl local pppoe-llc (dsl0, MTU 1492, quantum 1492)
:       class voip (1:11, prio 0)
:       class interactive (1:12, prio 1)
:       class facetime (1:13, prio 2)
:       class vpns (1:14, prio 3)
:       class surfing (1:15, prio 4)
:       class torrents (1:16, prio 5)
:       class default (1:5000, prio 6)


All Done!. Enjoy...
bye...
~~~~

FireQOS added the `default` class again.

Let's now see what is happening to traffic:

~~~~ {.programoutput}
# sudo fireqos status world-out
FireQOS v1.0 DEVELOPMENT
(C) 2013 Costa Tsaousis, GPL

world-out: dsl0 output => dsl0, type: adsl, overhead: 40
Rate: 800Kbit/s, min: 12Kbit/s
Values in Kbit/s

 CLASS   voip intera faceti   vpns surfin torren defaul
CLASSI   1:11   1:12   1:13   1:14   1:15   1:16 1:5000
PRIORI      0      1      2      3      4      5      6
COMMIT     12     12     12     12     12     12     12
   MAX    800    800    800    800    800    800    800


   world-out (dsl0 output => dsl0) - values in Kbit/s
 TOTAL   voip intera faceti   vpns surfin torren defaul
   787      -      -      -      -      -      -    787
   783      -      -      -      -      -      -    783
   789      -      -      -      -      -      -    789
   781      -      -      -      -      -      -    781
   794      -      -      -      -      -      -    794
   778      -      -      -      -      -      -    778
   787      -      -      -      -      -      -    787
   784      -      -      -      -      -      -    784
   783      -      -      -      -      -      -    783
   785      -      -      -      -      -      -    785
~~~~

Ok. Traffic is still at the default class.

We are now ready to classify traffic.

3. Classifying Traffic
----------------------

Classification is the process of assigning traffic to classes. Once all
traffic is assigned to classes, we will discuss traffic shaping.

**To ensure we will not disrupt the currently running traffic**,
before we start experimenting with traffic classification, there is one
change we have to make to our configuration. The way our configuration
is now, each class is assigned a different priority. You can find this
priority as `prio X` in FireQOS output when we applied our
configuration, but also as the PRIORITY line in FireQOS status output.
The priority is increased for every class. The class with the higher
priority is the first (`prio 0`). For the moment we need all classes to
have the same priority, to ensure no class can monopolise the available
traffic. To accomplish this, we just add the keyword `balanced` to each
interface, like this:

<%= include_example("qos-tutorial-05") %>

If you apply this configuration, you will get exactly the same result as
before, but this time all classes will have `prio 4`. This ensures that
once we assign some traffic to higher priority classes, these classes
will not monopolise the available bandwidth. Of course, classes should
have different priorities to achieve our goal. We will assign them
priorities at the next step, where we will discuss traffic shaping. For
the moment, this `balanced` policy allows us to experiment with
classification, without worrying about the currently running traffic. We
will not disrupt it.

* * * * *

To classify traffic, we define `match` statements within each class.
Each `match` statement will match some traffic and move it off the
`default` class, to the class the `match` statement appears under.

We can `match` traffic using the various characteristics of the packets.
The key characteristics would be: source or destination ports and
protocols. FireQOS supports more matches, like source or destination
IPs, TOS (Type Of Service), iptables MARKs, TCP options (ACKs, SYNs).

Keep in mind that, unlike FireHOL where you are expected to be very
precise on the traffic you allow, in FireQOS it is perfectly acceptable
to loosely match traffic. You can match whole blocks of IPs or ports,
even blocks that should never occur. This will not affect your security,
or traffic control quality.

### Classifying normal internet surfing traffic

Almost all servers who serve us for "normal internet surfing" listen on
TCP ports ranging from 0 to 1023. http is tcp/80, https is tcp/443, imap
is tcp/143, imaps is tcp/993, smtp is tcp/25, smtps is tcp/465, etc.

In the incoming direction (`input` interface), traffic is coming to our
network from these ports. So to classify surfing traffic, we could do
`match tcp sports 0:1023`. `sports` stands for source ports.

In the outgoing direction (`output` interface), traffic is going out
from our network to these ports. So, we could do
`match tcp dports 0:1023`. `dports` stands for destination ports.

Lets see it:

<%= include_example("qos-tutorial-06") %>

Apply it (it will not disrupt the traffic):

~~~~ {.programoutput}
# sudo fireqos start
FireQOS v1.0 DEVELOPMENT
(C) 2013 Costa Tsaousis, GPL


: interface dsl0 world-in input rate 12000kbit adsl local pppoe-llc balanced (fireqos-ifb1, MTU 1492, quantum 1492)
:       class voip (1:11, prio 4)
:       class interactive (1:12, prio 4)
:       class facetime (1:13, prio 4)
:       class vpns (1:14, prio 4)
:       class surfing (1:15, prio 4)
:       class torrents (1:16, prio 4)
:       class default (1:5000, prio 4)

: interface dsl0 world-out output rate 800kbit adsl local pppoe-llc balanced (dsl0, MTU 1492, quantum 1492)
:       class voip (1:11, prio 4)
:       class interactive (1:12, prio 4)
:       class facetime (1:13, prio 4)
:       class vpns (1:14, prio 4)
:       class surfing (1:15, prio 4)
:       class torrents (1:16, prio 4)
:       class default (1:5000, prio 4)


All Done!. Enjoy...
bye...
~~~~

Applied! FireQOS gave `prio 4` to all classes as it was asked to, by the
`balanced` keyword.

Lets now see the traffic:

~~~~ {.programoutput}
# sudo fireqos status world-out
FireQOS v1.0 DEVELOPMENT
(C) 2013 Costa Tsaousis, GPL

world-out: dsl0 output => dsl0, type: adsl, overhead: 40
Rate: 800Kbit/s, min: 12Kbit/s
Values in Kbit/s

 CLASS   voip intera faceti   vpns surfin torren defaul
CLASSI   1:11   1:12   1:13   1:14   1:15   1:16 1:5000
PRIORI      4      4      4      4      4      4      4
COMMIT     12     12     12     12     12     12     12
   MAX    800    800    800    800    800    800    800


   world-out (dsl0 output => dsl0) - values in Kbit/s
 TOTAL   voip intera faceti   vpns surfin torren defaul
   833      -      -      -      -     10      -    823
   785      -      -      -      -     14      -    771
   789      -      -      -      -     33      -    756
   788      -      -      -      -     73      -    715
   779      -      -      -      -    285      -    494
   781      -      -      -      -    257      -    524
   786      -      -      -      -     64      -    722
   794      -      -      -      -     18      -    776
~~~~

Nice. As you can see, the `surfing` class got some traffic. This is
normal internet surfing traffic going out (I asked status on
`world-out`).

### Classifying interactive traffic

I consider interactive traffic: DNS, ICMP (and ping), ssh and instant
messaging.

DNS is udp/53. Since I also run a DNS server, I want to match either
source or destination port 53 for both inbound and outbound traffic.
This is done automatically with the `port` match, like this:
`match udp port 53`.

SSH is tcp/22. I do run an SSH server too, so I'll match source or
destinations port: `match tcp port 22`.

ICMP and ping can be matched with `match icmp`.

For instant messaging I use gtalk. Gtalk is XMPP (Jabber) based, which
means it uses ports tcp/5222 and tcp/5228. For `input` I'll use
`match tcp sports 5222,5228` matching the source ports of incoming
traffic, while for `output` I'll use `match tcp dports 5222,5228`
matching the destination ports of outgoing traffic.

I also use Apple's push notifications which use tcp/5223. Since this is
a server on the internet, I'll match the source ports on `input` and the
destination ports on `output`.

Here are all together in the configuration:

<%= include_example("qos-tutorial-07") %>

### Classifying VoIP, VPNs and Facetime traffic

For VoIP I use SIP. SIP is udp/5060. I will match both source and
destination ports, since my asterisk listens on this port too:
`match udp port 5060`.

However port udp/5060 is just for signalling. SIP uses RTP to carry out
the phone audio. RTP can use any port. The client and server negotiate
these ports dynamically. We can however influence this ports election at
least for our side. I have configured my asterisk server
(`/etc/asterisk/rtp.conf`) to use ports 10000 to 10100 for RTP, so we
can now match RTP as UDP traffic (RTP is matched as UDP) that on our end
uses ports 10000-10100. For the `input` interface we'll use
`match udp dports 10000:10100` since only my asterisk server is using
these ports. Similarly for the `output` interface, we'll use
`match udp sports 10000:10100` (my asterisk box will be transmitting
from these ports, so I am matching the source ports of the outgoing
packets).

SIP devices are also using the STUN protocol to discover the type of NAT
available. STUN is using ports 3478 and 5349 both TCP and UDP. Since
these ports are the server ports available on the internet, I'll match
source ports on incoming traffic (`match sports 3478,5349`) and
destination ports on outgoing traffic (`match dports 3478,5349`). I did
not specify TCP or UDP, so that any of them will be matched.

For Facetime, I googled around and found that Facetime is using UDP
ports in the ranges 3478-3497, 16384-16387, 16393-16402. I will match
these ports both as source and destination:
`match udp ports 3478:3497,16384:16387,16393:16402` on both `input` and
`output`.

For VPNs, I use PPtP and OpenVPN.

PPtP is using port tcp/1723 for signalling. I use PPtP as a client, but
I also run an PPtP server. Therefore I'll match either source or
destination ports in both directions: `match tcp port 1723`. Once a PPtP
tunnel is established it sends packets over the GRE protocol:
`match gre`.

For OpenVPN I have 4 permanent tunnels on ports 1195 to 1198. From time
to time though I use these tunnels over TCP or UDP. So I'll omit the
protocol to match any of them. Since I run the OpenVPN server, for
`input` I'll match the destination ports: `match dport 1195:1198`, while
for `output` I'll match the source ports: `match sport 1195:1198`.

<%= include_example("qos-tutorial-08") %>

### Classifying torrents

Torrent clients are supposed to be using ports 6881 to 6999. However,
most modern clients are using random high numbered ports. Unfortunately,
torrents cannot be matched. The torrent clients exchange traffic at
random ports and they use encryption, making it impossible to match them
by port or the data exchanged. What can we do then?

So far, we have classified all important traffic to classes and left the
torrents go to the default class.

We can leave it like that. However, there will always be some traffic we
didn't classify in the classes above. For example, a web server on the
internet is using an unusual port number, or we opened a networked game
that uses unusual port numbers. This traffic will be competing with
torrents. It will be an unfair fight, since a single socket may be
competing with dozens or hundreds of torrent sockets.

There are three things we can do to settle this issue:

1.  Match as much as possible of torrents, in the torrents class. We
    will never match all of it. But we should try to match as much as
    possible.

    If you control the torrent clients and your clients have a
    configuration for setting fixed port(s) for them, I suggest to take
    the opportunity and use predefined ports, instead of random ones.
    For example, I have mine set to use port 60000 for incoming requests
    and ports 60001 to 65535 for outgoing request.
    If you do set ports for your torrent clients, we can match these ports
    at the `torrents` class using `match dport 60000:65535` on `input` and
    `match sport 60000:65535` on `output` interfaces. I also add `prio 1`
    to these matches, just to make sure that if a smart guy on the net puts
    his client on a port from 0 to 1023, the rule that matches the fixed
    torrent ports will be executed first.

    If you do set your torrent clients to use such port ranges, it would
    be also helpful to exclude these ports from other uses. One such use
    is the clients on the firewall itself. If you have installed, for
    example a transparent proxy with squid, you should instruct your
    proxy to avoid using the torrents ports. This can be done by executing
    this command `sysctl -w net.ipv4.ip_local_port_range=32768\ 59999`.
    This command will enforce all the clients of your firewall to avoid
    using the torrents ports.

    You can also instruct the masquerade of your internet interface to
    avoid mapping LAN clients on the torrents ports. This can be done
    by replacing your `masquerade4 ppp+` command in `firehol.conf` with
    `masquerade to-ports 32768-59999 ppp+`.

    Another more adventurous trick, is to match packets having source
    and destination ports above 16384. It is very unlikely that an
    internet server is listening on a port above 16384. So it is
    relatively safe to assume that almost all packets with source and
    destination ports above 16384 are torrent packets. Keep in mind
    though that this may also match other peer-to-peer traffic taking
    place in random high numbered ports, like Skype calls.

2.  Make sure the torrents class has a lower priority than the `default`
    class that is automatically added by FireQOS. By default, the
    `default` class has the lowest priority of all other classes.

    We will add the `default` class ourselves, just above torrents.

3.  Even if a few torrent sockets end up in the `default` class, I would
    like to have all TCP handshake packets of the traffic in the
    `default` class, preferred over the packets with data in them. So,
    the handshake of a new socket going out or coming in, will be
    preferred over the torrent packets. TCP handshake packets are
    packets with the SYN option set and small packets with the ACK
    option set. I'll add a new class `synacks` just above `default`.

<%= include_example("qos-tutorial-09") %>

Lets activate it. All traffic should now be classified in classes, but
no shaping will occur for any class. We do not expect to disrupt the
current traffic. Running this will just allow us to see the traffic we
have assigned in every class. Traffic will still be competing with each
other, much like it is done without traffic control in place.

~~~~ {.programoutput}
# sudo fireqos start
FireQOS v1.0 DEVELOPMENT
(C) 2013 Costa Tsaousis, GPL

: interface dsl0 world-in input rate 12000kbit adsl local pppoe-llc balanced (fireqos-ifb1, MTU 1492, quantum 1492)
:       class voip (1:11, prio 4)
:       class interactive (1:12, prio 4)
:       class facetime (1:13, prio 4)
:       class vpns (1:14, prio 4)
:       class surfing (1:15, prio 4)
:       class synacks (1:16, prio 4)
:       class default (1:5000, prio 4)
:       class torrents (1:18, prio 4)

: interface dsl0 world-out output rate 800kbit adsl local pppoe-llc balanced (dsl0, MTU 1492, quantum 1492)
:       class voip (1:11, prio 4)
:       class interactive (1:12, prio 4)
:       class facetime (1:13, prio 4)
:       class vpns (1:14, prio 4)
:       class surfing (1:15, prio 4)
:       class synacks (1:16, prio 4)
:       class default (1:5000, prio 4)
:       class torrents (1:18, prio 4)


All Done!. Enjoy...
bye...
~~~~

Lets now see the traffic:

~~~~ {.programoutput}
# sudo fireqos status world-out
FireQOS v1.0 DEVELOPMENT
(C) 2013 Costa Tsaousis, GPL

world-out: dsl0 output => dsl0, type: adsl, overhead: 40
Rate: 800Kbit/s, min: 12Kbit/s
Values in Kbit/s

 CLASS   voip intera faceti   vpns surfin synack defaul torren
CLASSI   1:11   1:12   1:13   1:14   1:15   1:16 1:5000   1:18
PRIORI      4      4      4      4      4      4      4      4
COMMIT     12     12     12     12     12     12     12     12
   MAX    800    800    800    800    800    800    800    800


   world-out (dsl0 output => dsl0) - values in Kbit/s
 TOTAL   voip intera faceti   vpns surfin synack defaul torren
   806      -      -      -     33     21     25     10    717
   790      -      -      -     45    358     11      9    366
   795     28      -      -     29    142      6      8    582 # I started a VoIP call, check voip
   797     59      -      -     47     50      8     30    601
   803     54      -      -     41    355      1     11    341 # balancing, check surfing and torrents
   803     33      -      -     35     68      9    313    345 # balancing, check default and torrents
   798     23      -      -     44     15     11    357    348
   783      7      -      -     35      1      8    201    532
   798      -      3      -     39      -      8     14    735
   798      -      1      -     37     13      8     18    721
   787      -      -      -     18     83      1    348    337
   789      -      -      -     53    246      3    244    243 # balancing, check surfing, default, torrents
^C
~~~~

Nice. This was the `output` interface. Lets check the `input` too:

~~~~ {.programoutput}
# sudo fireqos status world-in
FireQOS v1.0 DEVELOPMENT
(C) 2013 Costa Tsaousis, GPL

world-in: dsl0 input => fireqos-ifb1, type: adsl, overhead: 40
Rate: 12000Kbit/s, min: 120Kbit/s
Values in Kbit/s

 CLASS   voip intera faceti   vpns surfin synack defaul torren
CLASSI   1:11   1:12   1:13   1:14   1:15   1:16 1:5000   1:18
PRIORI      4      4      4      4      4      4      4      4
COMMIT    120    120    120    120    120    120    120    120
   MAX  12000  12000  12000  12000  12000  12000  12000  12000


   world-in (dsl0 input => fireqos-ifb1) - values in Kbit/s
 TOTAL   voip intera faceti   vpns surfin synack defaul torren
  2744      -      -      -      4      -     15    208   2517
  3553      -     14      -      4      2     10     50   3473
  2921      -      -      -    524      -     18     10   2369 # access to my VPN camera
  5976      -      -      -    354   3728     17      7   1871
 10114      -      -      -    682   7850     18    226   1338
  4125      -      -      -    237   1769     17    101   2002
  3727     17      2      -    340      1      4    322   3040 # a voip call again
  2212     31      -      -    569      1     11     64   1536
  2899     32      -      -    546     35     20     49   2216
  2104     33      -      -    329      -     24    245   1473
  3410      -      2      -    757      -      4     39   2608
  3643      -      -      -      -      -      1    171   3470
  4026      -      -      -      -      7      1      4   4014
^C
~~~~

Perfect!

So far we have classified all traffic and we have verified this
classification works. We haven't done any actual traffic control yet.
All classes are balanced with each other and packets are just competing
with each other. It is the best we can get for not disrupting the
currently running traffic.

It is now time to discuss traffic shaping.

4. Traffic Shaping
------------------

Traffic shaping is achieved by controlling how bandwidth is allocated to
classes.

We can control traffic allocation to classes by tweaking the following:

1.  Each class has a **committed rate**. A committed rate is the
    bandwidth a class will always get, when it needs it (only when it
    needs it).

    The committed bandwidth of a class that is not currently used by the
    class it is assigned to, I call it **spare bandwidth**. It is
    bandwidth that although it is committed to a class, this class does
    not currently need it and it is made available to other classes as
    **spare bandwidth**.

    By default, FireQOS commits 1/100th of the interface rate to each
    class. You can overwrite this default of all classes, by appending
    `minrate XXXX` to the interface.

    You commit bandwidth to classes by appending 'commit X' to a class,
    where `X` can be a speed definition, similar to the `rate` of
    interfaces.

    If you overcommit the interface rate, FireQOS will warn you. Do not
    overcommit the interface bandwidth. If you leave some interface
    bandwidth uncommitted, it will be available as spare bandwidth.

2.  Each class has a **maximum or ceiling rate**. This ceiling rate
    defines if the class can exceed its committed rate, and up to which
    rate. For a class to exceed its committed rate, there needs to be
    **spare bandwidth** available. If there is no spare bandwidth
    available, the class cannot exceed its committed rate.

    By default, FireQOS allows all classes to reach the interface speed,
    utilising all spare bandwidth available.

    You can define a ceiling rate by appending `max X` to a class, where
    `X` is a speed definition.

3.  Each class has a **priority**. The priority gives the importance of
    the class, compared to the other classes, when to comes to spare
    bandwidth allocation. Priority has nothing to do with their
    committed rate. The committed rate of a class will always be given
    to the class it is assigned to, when it needs it. The priority
    controls only spare bandwidth allocation. Here is how it works:

    ​i. **Two classes with the same priority**, that both need all the
    bandwidth they can get, they will get spare bandwidth proportionally
    to their committed rate. So if class A has 1Mbit committed rate and
    class B has 2Mbit committed rate, class B will get twice the spare
    bandwidth of class A. In all cases all spare bandwidth will be given
    to them.

    ​ii. **The class with highest priority** will get all the spare
    bandwidth there is, of course only when it needs it.

    ​iii. **The class with lowest priority** will get spare bandwidth
    only when all other classes (with higher priorities) do not need it.

    By default, FireQOS assigns priorities to classes in the order they
    appear in the configuration file. The most important class with the
    highest priority is the first. If we add the `balanced` keyword to
    the interface (or class groups), then all classes will be given the
    same priority (`prio 4`).

    `prio 0` is the highest priority (lower number = higher priority).
    HTB and therefore FireQOS supports only 8 priorities for classes (0
    to 7).

    You can assign a priority to a class by using `prio X`, where `X` is
    a number between 0 and 7. It can also be the keyword `last`, or
    `keep`, in which case the class will get the same priority as the
    class just above it.

* * * * *

To commit traffic to classes, I prefer to think like this:

**Assume all the classes need all the bandwidth they can get. **Every
single class needs all the bandwidth the interface can provide.** Under
this extreme case, how the interface bandwidth should be distributed to
classes?**\*

This is an easier question to answer:

1.  `voip`: we just need 100kbit for supporting 3x g.729 concurrent
    calls.

2.  `synacks`, `default` and `torrents`: we don't care even if they
    stop, so 1% each is fine. Remember that `synacks` matches only the
    TCP SYNs and ACKs for traffic in the `default` class. SYNs and ACKs
    of more important classes have already been matched (matches are
    executed in the order they appear and since matches for the more
    important classes has already been done above, the `synacks` class
    `match` statements match only traffic not already matched before).

3.  `interactive`, 20% (dns, ssh, icmp).

4.  `facetime`, 200kbit.

5.  `vpns`, 20%.

6.  `surfing`, 30% download, 5% upload.

<%= include_example("qos-tutorial-09b") %>

All the bandwidth I have not committed to classes, will be considered
**spare bandwidth**.

Regarding priorities, we now have 3 options:

1.  Leave the classes `balanced`, with exactly the same priority. This
    means that if there is spare bandwidth, all the classes will get
    some of this, proportionally to their committed rate.

    This is a good plan. The committed rates I gave will not allow
    torrents to be a problem and proportionally sharing all spare
    bandwidth seems logical. Generally I prefer this plan on production
    servers where all classes have traffic all the time.

2.  Remove the `balanced` keyword, so that the most important class that
    needs more bandwidth can get all the spare bandwidth available.

    This is a bit more aggressive. However, it will provide the feeling
    to my VPN and ssh sessions, that the link is always idle. It will be
    a lot more responsive to sudden bursts and spikes on the most
    important classes.

    There is a risk though. If for some reason we get a DoS attack on a
    more important class, all spare bandwidth will be given to the
    attacker.

    Generally, I prefer this plan for my home. I don't care about
    monopolising all spare bandwidth on the task I perform. Actually I
    like the opposite: all my interactive sessions to be as interactive
    as possible.

3.  Keep priorities `balanced`, but assign different priorities to
    certain classes. In our example, we could assign `prio 0` to `voip`,
    `prio 1` to `interactive`, `prio 5` to `synacks`, `prio 6` to
    `default` and `prio 7` to `torrents`.

    or, the same can be achieved with this:

    Remove `balanced`, so that all classes get an incremental priority
    starting from 0, and assign `prio 2` (the priority of `facetime`) to
    `vpns` and `surfing`.

    Both will have the same effect.

I will go with plan 2, the aggressive one. Here it is:

<%= include_example("qos-tutorial-10") %>

Apply it:

~~~~ {.programoutput}
# sudo fireqos start
FireQOS v1.0 DEVELOPMENT
(C) 2013 Costa Tsaousis, GPL

: interface dsl0 world-in input rate 12000kbit adsl local pppoe-llc (fireqos-ifb1, MTU 1492, quantum 1492)
:       class voip commit 100kbit (1:11, prio 0)
:       class interactive commit 20% (1:12, prio 1)
:       class facetime commit 200kbit (1:13, prio 2)
:       class vpns commit 20% (1:14, prio 3)
:       class surfing commit 30% (1:15, prio 4)
:       class synacks (1:16, prio 5)
:       class default (1:5000, prio 6)
:       class torrents (1:18, prio 7)

: interface dsl0 world-out output rate 800kbit adsl local pppoe-llc (dsl0, MTU 1492, quantum 1492)
:       class voip commit 100kbit (1:11, prio 0)
:       class interactive commit 20% (1:12, prio 1)
:       class facetime commit 200kbit (1:13, prio 2)
:       class vpns commit 20% (1:14, prio 3)
:       class surfing commit 5% (1:15, prio 4)
:       class synacks (1:16, prio 5)
:       class default (1:5000, prio 6)
:       class torrents (1:18, prio 7)


All Done!. Enjoy...
bye...
~~~~

Lets test it with an ADSL speed tester, first the `input` interface:

~~~~ {.programoutput}
# sudo fireqos status world-in
FireQOS v1.0 DEVELOPMENT
(C) 2013 Costa Tsaousis, GPL

world-in: dsl0 input => fireqos-ifb1, type: adsl, overhead: 40
Rate: 12000Kbit/s, min: 120Kbit/s
Values in Kbit/s

 CLASS   voip intera faceti   vpns surfin synack defaul torren
CLASSI   1:11   1:12   1:13   1:14   1:15   1:16 1:5000   1:18
PRIORI      0      1      2      3      4      5      6      7
COMMIT    120   2400    200   2400   3600    120    120    120
   MAX  12000  12000  12000  12000  12000  12000  12000  12000


   world-in (dsl0 input => fireqos-ifb1) - values in Kbit/s
 TOTAL   voip intera faceti   vpns surfin synack defaul torren
  5105      -      -      -      3      3      3    338   4759
  6111      -      2      -     14      -      5    326   5763
  6849      -      6      -      6      1      5    216   6615
  6370      -      8      -      2     11     10    195   6144
 10860      -      -      -      5   8270      4    329   2251 # speed test initiated
 12135      -      -      -     15   9347      3    353   2418
 12069      -      -      -     15  10025      5    164   1860
 12102      -      -      -    408  10696      1    323    673
 12038      -      -      -    572  11196      4    133    133 # torrents shaped to their committed rate
 12079      -      -      -      4  11760      1    155    159
 12075      -      -      -      9  11825      3    120    118
  1814      -      -      -      4    358      9    601    842
  3750      -      3      -      3      -     13    186   3546 # torrents are recovering
  4126      -      2      -      8      -      8    197   3911
  4434     15      3      -      5      -      3    187   4220
^C
~~~~

Remember, if you want traffic to be shaped faster in the inbound
direction, use 90% or 85% of the incoming bandwidth.

Lets see the `output`:

~~~~ {.programoutput}
# sudo fireqos status world-out
FireQOS v1.0 DEVELOPMENT
(C) 2013 Costa Tsaousis, GPL

world-out: dsl0 output => dsl0, type: adsl, overhead: 40
Rate: 800Kbit/s, min: 12Kbit/s
Values in Kbit/s

 CLASS   voip intera faceti   vpns surfin synack defaul torren
CLASSI   1:11   1:12   1:13   1:14   1:15   1:16 1:5000   1:18
PRIORI      0      1      2      3      4      5      6      7
COMMIT    100    160    200    160     40     12     12     12
   MAX    800    800    800    800    800    800    800    800


   world-out (dsl0 output => dsl0) - values in Kbit/s
 TOTAL   voip intera faceti   vpns surfin synack defaul torren
   791      -      4      -      -     21     24      9    733
   792      -      3      -      2      1     23     56    708
   800      -      -      -      1      -     22    128    649
   773      -      -      -      -      -     28    109    635
   809      -      -      -      1    656     12     60     79 # upload test started
   809      -      -      -      3    773      8     15     10
   813      -      -      -      -    787      5     11     11
   795      -      -      -      -    746      8     19     22
   811      -      -      -      -    802      3      5      2
   817      -      1      -      -    801      2      -     13
   796      -      1      -      -    773      -     12     10
   813      -      -      -     16    773      3     11     10
   803      -      -      -      1    755     11     23     13 # upload test ended
   803      -      -      -     13      -      3    225    562
   790      -      -      -     36      -     20     29    706
   743      -      -      -      2      -     11      6    725
^C
~~~~

Excellent! Traffic shaping works as expected.

Final Notes
-----------

There are just a few extra considerations, listed below.

### Traffic Control on Very Busy Servers

If your kernel does not support `fq_codel` or `codel`, on very busy
servers with thousands of concurrent clients, you may see small and
random packet drops on the busiest classes, even when there is plenty of
bandwidth available. This happens because an `sfq` qdisc (one `sfq`
qdisc is added to every class, by default) has a very small queue size.
If this queue becomes full (for example due to a burst), the class
around the full qdisc has no place to deliver the packet, and therefore
it drops it. This issue does not exist if your kernel has `fq_codel` or
`codel` available. FireQOS will use these instead of `sfq`.

If you don't have `fq_codel` or `codel` available, you can overcome the
problem by replacing the `sfq` qdisc with `pfifo`. `pfifo` uses a queue
size that is equal to the queue size of the underlying interface, so
packet loss should only occur when the interface in also congested.

To replace `sfq` with `pfifo` just append `qdisc pfifo` to any class or
the interface. If you append it to an interface, then all classes within
this interface will get `pfifo` by default.

* * * * *

To have finer control over traffic control, FireQOS specifies by default
a `quantum` of size equal the MTU of the interface. It also leaves
`burst` and `cburst` to their kernel default values, which also assigns
to them values very close to MTU.

Although I have not experienced any issues with these settings, even on
a few very busy servers, I have seen notes on various places that htb's
full speed depends on these values, in relation to the clock of the
machine it is running, which also affects the cpu load of the machine.

As a precaution, on very busy servers I add
`quantum 150000 burst 150000 cburst 150000` at the interface with huge
amounts of traffic. These values allow HTB to move traffic in chunks of
100 x MTU, thus allowing to perform faster, while of course loosing some
traffic control detail in the process.

* * * * *

It is also advised that for traffic control to work on very busy
servers, you should disable CPU offloading of the Ethernet network card,
by running: `ethtool -K ethX tso off gso off gro off` (where ethX your
Ethernet device). It is said, that without disabling CPU offloading,
traffic control may be inaccurate.

This document explains everything in detail:
[http://www.novell.com/support/kb/doc.php?id=7002555](http://www.novell.com/support/kb/doc.php?id=7002555)
