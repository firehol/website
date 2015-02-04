---
title: Linux firewalling and traffic shaping for humans
submenu: home
---

<% entry = news_items.shift %>
<div id="latest-news">
  <h4>Latest News</h4>
  <p><%= news_date(entry) %> -
        <span class="news_title"><%= news_title(entry) %></span>
      <a href="/news/">[more ...]</a>
  </p>
</div>


What are FireHOL and FireQOS?
=============================

FireHOL is a language (and a program to run it) which builds secure,
stateful firewalls from easy to understand, human-readable
configurations. The configurations stay readable even for very complex
setups.

FireQOS is a program which sets up traffic shaping from an
easy-to-understand and flexible configuration file.

Both programs abstract away the differences between IPv4 and IPv6. so
you can concentrate on the rules you want. You can apply rules for IPv4
or IPv6, or both, as you need.

We think the best advert for these programs are their configurations.
See below for:

-   [a FireHOL example and more information](/#firehol)
-   [a FireQOS example and more information](/#fireqos)

The two programs are shipped together but work independently so you can
choose to use one or both.

Philosophy
----------

-   Make firewalling and traffic shaping an easy, straightforward task
    for everyone from end users to experienced administrators.
-   Be as secure as possible by allowing explicitly only the wanted
    traffic to flow.
-   Be a resource of knowledge around services and their peculiarities.
-   Be flexible enough for any firewalling or traffic-shaping need.
-   Be simple to install on any modern Linux system

FireHOL
-------

FireHOL is an iptables firewall generator producing stateful iptables
packet filtering firewalls, on Linux hosts and routers with any number
of network interfaces, any number of routes, any number of services
served, any number of complexity between variations of the services
(including positive and negative expressions).

Writing a complete, safe, firewall, suitable for protecting a host and a
network can be this easy:

<%= include_example('overview-01') %>

Jump straight to the [tutorials](/tutorial/) to learn how to configure
your own.

Hopefully you have noticed that all the rules given match just one
direction of the traffic: **the request**. They don't say anything about
replies. This is because FireHOL handles the replies automatically. You
don't have to do anything about them: if a request is allowed, then the
corresponding reply is also allowed. This also means that FireHOL
produces the iptables statements to exactly match what is allowed **in
both directions** and nothing more.

FireHOL is a **language to express firewalling rules**, not just a
script that produces some kind of a firewall.

### Is it secure?

FireHOL is **secure** because it has been designed with the right
firewalling concept: **deny everything, then allow only what is
needed**.

Also, FireHOL produces **stateful** iptables packet filtering firewalls
(and possibly, the only generic tool today that does that for all
services in both directions of the firewall).

Stateful means that traffic allowed to pass is part of a valid
connection that has been initiated the right way. Stateful also means
that you can have control based on who initiated the traffic. For
example: you can choose to be able to ping anyone on the internet, but
no one to be able to ping you. If for example you don't need to run a
server on your Linux host, you can easily achieve a situation where you
are able to do anything to anyone, but as far as the rest of world is
concerned, **you do not exist**!

### Learn another language?

FireHOL has been designed to allow you configure your firewall the same
way you think of it. Its language is extremely simple. Basically you
have to learn four commands:

-   <%= html_to('interface','/keyword/firehol/interface') %>, to
    setup a firewall on a network interface
-   <%= html_to('router','/keyword/firehol/router') %>, to setup a
    firewall on traffic routed from one network interface to another
-   <%= html_to('server','/keyword/firehol/server') %>, to setup a
    listening service within an interface or router. The same command
    can be used as <%= html_to('route','/keyword/firehol/server') %>
    within routers
-   <%= html_to('client','/keyword/firehol/client') %>, to setup a
    service client within an interface or router

Commands <%= html_to('client','/keyword/firehol/client') %> and <%=
html_to('server','/keyword/firehol/server') %> have exactly the same
syntax. A FireHOL <%=
html_to('interface','/keyword/firehol/interface') %> has two mandatory
arguments and a <%= html_to('router','/keyword/firehol/router') %>
has only one (and this is the same as one of the two that <%=
html_to('interface','/keyword/firehol/interface') %> requires). All of
the optional parameters are the same to all of them. This sounds like
just one command is to be learned...

Of course there are a few more commands defined, but all of them exist
just to give you finer control on these four.

If you don't believe it is simple, consider [this
example](/tutorial/firehol-by-goal/).

### Why?

As an IT executive, responsible for many dozens of Linux systems, I
needed a firewalling solution that would allow me and my team to have a
clear and simple view of what is happening on each server, as far as
firewalling is concerned. I also needed a solution that will allow my
team members to produce high quality and homogeneous firewalls
independently of their security skills and knowledge. After searching
for such a tool, I quickly concluded that no tool is flexible, open,
easy, and simple enough for what I needed.

I decided to write FireHOL in a way that will allow me, or anyone else,
to view, verify and audit the firewall of any Linux server or Linux
router **in seconds**. FireHOL's configuration is extremely simple...
you don't have to be an expert to design a complicated but secure
firewall.

### What features does it have?

FireHOL handles firewalls protecting one host on all its interfaces and
any combination of stateful firewalls routing traffic from one interface
to another. There are no limitations on the number of interfaces or on
the number of routing routes (except the ones iptables has, if any).

FireHOL, still lacks a few features: QoS for example is not supported
directly. You are welcome to extend FireHOL and send me your patches to
integrate within FireHOL. In any case however, you can embed normal
iptables commands in a FireHOL configuration to do whatever iptables
supports.

Since FireHOL produces stateful commands, for every supported service it
needs to know the flow of requests and replies. Today FireHOL supports
the following services:

-   Many single socket protocols, such as HTTP, NNTP, SMTP, POP3, IMAP4,
    RADIUS, SSH, LDAP, MySQL, Telnet, NTP, DNS, etc. There are a few
    dozens of such services defined in FireHOL. Check [this
    list](/services/). Even if something is missing, you can [define
    it](/guides/adding-services/).
-   Many complex protocols, such as FTP, NFS, SAMBA, PPTP, etc. If you
    need some complex protocol that is not present, you will have to
    program it (in simple Bash scripting - there are many commented
    examples on how this is done). Again, you will just create one Bash
    function with the rules of the protocol, and FireHOL will turn it to
    a client, a server or a router.

FireQOS
-------

FireQOS is a traffic shaping helper. It has a very simple shell
scripting language to express traffic shaping. You run FireQOS to setup
the kernel commands. You can also run it to get status information or
dump the traffic of a class. FireQOS is not a daemon and does not need
to run always to apply traffic shaping.

Configuring a complete, functional, traffic shaping setup can be this
easy:

<%= include_example('overview-qos-01') %>

Jump straight to the [tutorials](/tutorial/) to learn how to configure
your own.

FireQOS also allows you to monitor the live status of traffic:

~~~~ {.programoutput}
# ./sbin/fireqos.in status adsl-in
FireQOS v1.0 DEVELOPMENT
(C) 2013 Costa Tsaousis, GPL


adsl-in: eth0 input => ifb0, type: adsl, overhead: 26
Rate: 10500Kbit/s, min: 105Kbit/s, R2Q: 8 (min rate 105Kbit/s)
Values in Kbit/s

  CLASS    voip realtim clients torrent default
PRIORIT       1       2       3       5       4
 COMMIT     105    1050    1050     105     105
    MAX   10500   10500   10500    9450    9450


   adsl-in (eth0 input => ifb0) - values in Kbit/s
  TOTAL    voip realtim clients torrent default
     46       -       7       -      39       -
     50       -       5       -      42       3
     80       -       9       -      60      11
     75       -       6       -      65       4
    103      19       3       -      79       2
     56       -       3       -      50       3
     84       -       5       -      70       9
~~~~

-   FireQOS applies traffic shaping on the output of any interface.
-   FireQOS applies traffic shaping on the input of any interface.
    Shaping incoming traffic is classful, i.e. you have all the control
    available, similar to outgoing traffic. This is accomplished by
    setting up IFB devices. FireQOS handles everything about IFB
    devices. Any kernel that supports them will do.
-   FireQOS supports overheads calculation. This means it can perfectly
    shape incoming and outgoing traffic on a Linux box behind an ADSL
    router, or on a Linux box with an ADSL modem attached. ATM overheads
    will be calculated based on the DSL encapsulation.
-   FireQOS supports both IPv4 and IPv6. Each interface can be defined
    as ipv4, ipv6 or both (ipv4 and ipv6 in parallel).
-   FireQOS supports nested classes. Nested classes can either be direct
    (child classes are directly attached to their parent class), or
    hardware emulation (child classes are attached to a qdisc with
    linklayer parameters and overheads calculation, which is attached to
    a parent class).
-   FireQOS calculates port range masks (you just give a port range,
    FireQOS finds the optimal combination of tc statements to accomplish
    the match).
-   Virtually any number of interfaces, any number of classes and any
    number of classification rules can be configured (the way it is
    organised it can configure up to 5000 classes per interface).
-   It classifies packets using tc (both ipv4 and ipv6), but you can
    also use iptables CLASSIFY targets, or MARKs.
-   [HTB](http://luxik.cdi.cz/%7Edevik/qos/htb/manual/userg.htm) is used
    for all classes.
-   FireQOS allows you to tcpdump the traffic of any leaf class. This
    allows you to examine the traffic you have assigned to classes.

<br/>
<br/>
Hosting by: <a target="_blank" href="http://www.foxyhosting.cz/"><img
               alt="www.foxyhosting.cz"
               src="/images/foxyhosting.png"/></a>
<br/>
<br/>
