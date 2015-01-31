---
title: Troubleshooting
submenu: documentation
---

Troubleshooting
===============

Troubleshooting a running firewall is relatively simple and for almost
all iptables firewalls the means you have are the same tool, **the
system log**. This is typically `/var/log/messages`{.filename},
`/var/log/syslog`{.filename} or similar.

Reading log output
------------------

The system log will log any packets dropped **implicitly** by FireHOL.
This means any packets which do not match any rules in the configuration
file.

FireHOL always logs packets not matched by any rule, although it does
not log every single packet, in order to protect you from an attack that
could use all of your free hard disk space. The rate is controlled in
the same way as <%= html_to('loglimit','/keyword/firehol/loglimit')
%>.

In the system log you will find entries that look like:

~~~~ {.programoutput}
Dec 21 20:01:07 gateway kernel: IN-internet:IN=ppp0 OUT= MAC= \
  SRC=200.75.88.187 DST=195.97.5.193 LEN=78 TOS=0x00 PREC=0x00 \
  TTL=111 ID=63816 PROTO=UDP SPT=34165 DPT=137 LEN=58 

Dec 21 22:25:39 gateway kernel: OUT-unknown:IN= OUT=ppp0 \
  SRC=195.97.5.193 DST=192.168.23.1 LEN=48 TOS=0x00 PREC=0x00 \
  TTL=64 ID=0 DF PROTO=TCP SPT=139 DPT=1255 WINDOW=2128 \
  RES=0x00 ACK SYN URGP=0 
  
Dec 21 20:01:07 gateway kernel: PASS-unknown:IN=ppp0 OUT=eth0 \
  SRC=200.75.88.187 DST=195.97.5.194 LEN=78 TOS=0x00 PREC=0x00 \
  TTL=110 ID=64840 PROTO=UDP SPT=34132 DPT=137 LEN=58 
~~~~

Each of such lines represent one packet that did not satisfy the
requirements of the configuration file rules.

The important things to look in these logs are:

-   **Its reason text.**

     In FireHOL this has the form **IN-name**, **OUT-name**, **PASS-name**.

    -   **IN-name** matches packets that dropped at the end of the
        interface's **name** input. These are packets tried to come into
        this host (it is not routed traffic). \
         **Name** matches the name given to a FireHOL <%=
        html_to('interface','/keyword/firehol/interface') %> There is
        also the special name **unknown** that matches packets tried to
        come into this host but did not match any of the <%=
        html_to('interface','/keyword/firehol/interface') %>s given in
        FireHOL's configuration file.
    -   **OUT-name** matches packets that dropped at the end of the
        interface's **name** output. These are packets the host tried to
        send (it is not traffic routed). \
         **Name** matches the name given to a FireHOL <%=
        html_to('interface','/keyword/firehol/interface') %> There is
        also the special name **unknown** that matches packets that
        tried to go out of this host but did not match any of the <%=
        html_to('interface','/keyword/firehol/interface') %>s given in
        FireHOL's configuration file.
    -   **PASS-unknown** matches packets that dropped at the end of all
        <%= html_to('router','/keyword/firehol/router') %>s This
        matches forwarded traffic. \
         There is no **name** here, since all FireHOL <%=
        html_to('router','/keyword/firehol/router') %>s have only one
        <%= html_to('policy','/keyword/firehol/policy') %>
        **RETURN**. This makes all packets traverse all routers and then
        get dropped at the end of the firewall.

-   **IN=** gives the real network interface name the packet came in from.
    It can be empty when the packet was generated locally.
-   **OUT=** gives the real network interface name the packet tried to use
    to go out of this host
    It can be empty when the packet was to be received by the firewall
    host.
-   **SRC=** gives the IP address of the sender.
-   **DST=** gives the IP address of the packet's destination.
-   **PROTO=** gives the protocol this packet is using (TCP, UDP, ICMP,
    etc).
-   **SPT**= gives the source port number of this packet.
-   **DPT=** gives the destination port number of this packet.

Generally, you should monitor the system log for such entries and decide
if each entry was something useful or not. If it was something useful,
you should have added another service somewhere in your FireHOL
configuration to match that packet and allow it to reach its
destination. If it was not something useful, then FireHOL did the right
job and dropped it.

Keep in mind that there are certain cases where packets get dropped even
though FireHOL has specific rules that should allow them to pass. Such
cases are not always errors, and here is why:

The iptables connection tracker has a mechanism for matching request
packets and reply packets. When an allowed request comes in, the
connection tracker keeps it in a list and then waits for a matching
reply to come in the opposite direction. This list of **active
connections** is available for you to see at
`/proc/net/ip_conntrack`{.filename}. Simply `cat`{.command} this file to
see all the current connections your system has.

The connection tracker will wait for a reply a certain amount of time.
This time is, for example, about 20 seconds for UDP traffic. After that
time the connection tracker will remove the request from its list. A
reply that is send after the connection tracker has removed the request
from its list, will be dropped and therefore logged in the system log.

This situation may, for example, produce a few log entries in your DNS
server for cases where the DNS server could not respond within the time
limits set by iptables, but this is not a problem because the DNS client
had already timed out in 2 or 3 seconds.

Note however that the above are common when the connection tracker is
trying to keep a state on a stateless protocol (such as UDP or ICMP).
Stateful protocols, such as TCP, always respond immediately to
acknowledge the connection and therefore the time needed by the
application server to respond does not make the connection tracker to
remove the request from its list.
