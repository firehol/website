---
title: FireHOL v1.x New User Tutorial
submenu: documentation
---

FireHOL v1.x New User Tutorial
==============================

This is the recommended procedure to manually design a secure FireHOL
firewall. It applies to FireHOL 1.x versions, which only understand
IPv4.

1. Identify all network interfaces on your firewall host
--------------------------------------------------------

Network interfaces are there for some reason. You have to do something
about all the interfaces of your host. If you don't do something at the
firewall level with a network interface, then it depends of the firewall
policy what will happen with traffic on this interface. By default
FireHOL will `drop`{.action} all traffic coming in and going out via an
undefined network interface, so the network interface will have no
meaning to be up and running. This is a common mistake on some ADSL
configurations, where users ignore the loop device that connects the
Linux router with the ADSL device. To identify your network interfaces
use the `ip link show`{.command} command. The example below shows my
home router `ip link show`{.command} output:

~~~~ {.programoutput style="width: 100%;"}
[root@gateway /]# ip link show
1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,PROMISC,UP> mtu 1500 qdisc pfifo_fast qlen 100
    link/ether 00:50:fc:21:9a:ab brd ff:ff:ff:ff:ff:ff
12: ppp0: <POINTOPOINT,MULTICAST,NOARP,UP> mtu 1500 qdisc pfifo_fast qlen 3
    link/ppp
~~~~

There are a few important thinks to always remember:

-   `lo`{.interface} exists on all machines and is used for
    communication between programs running on this machine. FireHOL
    handles this automatically. You don't have to do anything about
    `lo`{.interface}.
-   Network interfaces (except the `lo`{.interface} interface) are used
    for two purposes:
    -   By the firewall host for its own communication with the rest of
        the world. This is the case when the firewall host requests
        something from some other host (a DNS lookup maybe) for its own
        needs, or when some other host requests something from the
        firewall host, when the later is running some daemons (servers)
        too.
    -   By other hosts as **gateways** in order to reach other hosts
        behind the firewall host. In this case, the firewall host simply
        passes traffic from one of its network interfaces to another.
        This is also called **routing**.

In the above example, it is clear that I have two network interfaces
(except `lo`{.interface}): `eth0`{.interface} and `ppp0`{.interface}.

One extra step is to identify if the network interfaces appearing here
might dynamically change during run-time. For example my
`ppp0`{.interface} might become `ppp1`{.interface} or `ppp2`{.interface}
in certain cases. To overcome this problem, I can say that my link to
the outside world is not `ppp0`{.interface} but `ppp+`{.interface}. The
plus character matches all the interfaces that **begin** with the text
given before the plus sign. In this case, it matches all the possible
network interfaces that start with `ppp`{.interface}.

Keep in mind that FireHOL (and iptables) does not really care if the
interface defined in a firewall actually exists or not. This means that
you can setup firewalls on interfaces that might become available later
or altered during run time. This also means that if you define an
interface with a wrong name, FireHOL and iptables will not complain.

2. Give a role to each interface identified
-------------------------------------------

Now I have to assign a role to each network interface, i.e. what is the
function of each of those interfaces? For this, I create a table similar
to the one below. It is important to focus on the requests; forget the
replies.

<div class="wide-table">

  interface            description    incoming requests                                                                             outgoing requests                                               routing requests in                                   routing requests out
  -------------------- -------------- --------------------------------------------------------------------------------------------- --------------------------------------------------------------- ----------------------------------------------------- -----------------------------------------------------
  `eth0`{.interface}   My home LAN    Many services from my LAN workstations (i.e. dns, ftp, samba, squid, dhcp, http, ssh, icmp)   A few services my LAN workstations provide (i.e. samba, icmp)   All LAN workstations requests going to the internet   Nothing
  `ppp+`{.interface}   The Internet   I run a public mailer, a public web server and a public ftp server for my domain              All the services my Linux could ask from the internet           Nothing                                               All LAN workstations requests going to the internet

</div>

Keep in mind that:

-   **incoming requests** represent **servers** running on the firewall
    host.
-   **outgoing requests** represent **clients** running on the firewall
    host.
-   **routing requests in** represent **clients** on hosts at the network
    interface in question.
-   **routing requests out** represent **servers** on hosts at the network
    interface in question.

So, the above could also be presented as:

<div class="wide-table">

  interface            name       servers provided                                clients used   routing clients   routing servers
  -------------------- ---------- ----------------------------------------------- -------------- ----------------- -----------------
  `eth0`{.interface}   home       dns, ftp, samba, squid, dhcp, http, ssh, icmp   samba, icmp    all               none
  `ppp+`{.interface}   internet   smtp, http, ftp                                 all            none              all

</div>

This table can easily be transformed into FireHOL rules.

3. Create the FireHOL configuration structure
---------------------------------------------

Now that you have a list of all the interfaces and their roles, it is
time to start writing the FireHOL configuration file. First write one
interface statement for each network interface you identified above:

<%= include_example("tutorial-v1-01") %>

Now, we can add the servers for each interface (based on the table
above). Remember that these servers are all running on the firewall
host:

<%= include_example("tutorial-v1-02") %>

Now, we can add the clients for each interface. Remember that these
clients are all running on the firewall host:

<%= include_example("tutorial-v1-03") %>

At this point, everyone should be able to inter-operate correctly with
the firewall host, but still we don't route any traffic. This means that
the linux box can "see" all the workstations on the LAN and these
workstations can "see" the linux box, also that the linux box can "see"
the Internet and the Internet can "see" the servers of the
`ppp+`{.interface} interface of the linux box, but the LAN workstations
cannot "see" the Internet.

It is now time to setup routing. To do this we will have to define a set
of routers for all the interface combinations. This means that if we
have two interfaces we will have to define two routers. If we have 3
interfaces, we will have to define 6 routers, and so on.

<%= include_example("tutorial-v1-04") %>

Remember that <%= html_to('inface','/keyword/firehol/inface') %> and
<%= html_to('outface','/keyword/firehol/outface') %> match the
**requests**, not the replies. This means that the router
**home2internet** matches all requests originated from
`eth0`{.interface} and going out to `ppp+`{.interface} (and of course
their relative replies in the opposite direction), while the router
**internet2home** matches all the requests from the Internet to the home
LAN (and their relative replies back).

Now, based on the roles table of the previous section we see that we
should route all requests coming in from `eth0`{.interface} and going
out to `ppp+`{.interface}, and not route any request coming from the
Internet and going out to the home LAN. Here it is:

<%= include_example("tutorial-v1-05") %>

This is it. We are done! (for the filtering part of the firewall. Look
below for setting up NAT too.)

4. Optimizing the firewall
--------------------------

To save typing time, you can use this:

<%= include_example("tutorial-v1-06") %>

Note that we can remove any <%=
html_to('router','/keyword/firehol/router') %> statements not having
any rules in them, so the **internet2home** router has been eliminated.

We might want to have extra checks on each interface to prevent
spoofing. To find the IPs of your network interfaces use
`ip addr show`{.command} and to find the IP networks behind each
interface use `ip route show`{.command}.

<%= include_example("tutorial-v1-07") %>

<%=
html_to('UNROUTABLE_IPS','/keyword/manref/firehol/variables-unroutable')
%> is a variable defined by FireHOL and contains all the IPs that
should not be routed on the internet.

If home LAN did not have real IP addresses, we would have to add a
masquerade command in our router:

<%= include_example("tutorial-v1-08") %>

The <%= html_to('masquerade','/keyword/firehol/masquerade') %>
command sets itself up on the <%=
html_to('outface','/keyword/firehol/outface') %> of a <%=
html_to('router','/keyword/firehol/router') %>.

We can now protect our ppp interface even further. For this we use the
<%= html_to('protection','/keyword/firehol/protection') %> command:

<%= include_example("tutorial-v1-09") %>

It could be nice if instead of dropping wrong packets originated from
the Ethernet, to reject them so that our workstations will not have to
timeout if we do something that is not allowed. To do this we use the
<%= html_to('policy','/keyword/firehol/policy') %> command:

<%= include_example("tutorial-v1-10") %>

Some servers on the Internet try to **ident** back the client to find
information about the user requesting the service. With our current
firewall, such servers will have to timeout before accepting our
request. To speed thinks up we could write:

<%= include_example("tutorial-v1-11") %>

Note that we now have added the router we eliminated above, since we
need to add a service to it.

The whole routing schema could be rewritten as:

<%= include_example("tutorial-v1-12") %>

Now we have elicited the first router, but we defined everything in the
second. We have used the *reverse* keyword in <%=
html_to('masquerade','/keyword/firehol/masquerade') %> to make it set
up in <%= html_to('inface','/keyword/firehol/inface') %> this time.

We could use the first router (home2internet) to do everything, but then
the <%= html_to('client','/keyword/firehol/client') %> and <%=
html_to('server','/keyword/firehol/server') %> commands would need be
reversed (server all, client ident) which would be confusing.
