---
title: OpenWRT installation
submenu: downloads
---

Installation on OpenWRT
=======================

For versions prior to Chaos Calmer,
[see this document](/installation/openwrt-old/).

From Chaos Calmer, OpenWRT no longer ships with a `make` package.
This make installation from source very difficult, so we now provide
[pre-built packages](https://github.com/firehol/packages/releases/latest).

The Bash dependency in particular is quite large, so needs a device with
a reasonable amount of storage.

I have been running FireHOL on an unmodified v1.5 [TP-Link
TL-WR1043ND](http://wiki.openwrt.org/toh/tp-link/tl-wr1043nd) without
trouble for a number of years. This device has 32MB RAM and 8MB flash.

At present the `firehol wizard`, `link-balancer`, `vnetbuild` and
`update-ipsets` are not included in the OpenWRT packages.

We will assume that your router's hostname is `openwrt` throughout this
document.

Install FireHOL and FireQOS
---------------------------

The `firehol*.ipk` packages are platform independent. Download the
version which matches your OpenWRT installation, then install it as
follows:

~~~~ {.programlisting}
scp firehol_3.1.1-1_all_chaos_calmer.ipk root@openwrt:/tmp
ssh root@openwrt
cd /tmp
opkg update
opkg install firehol_3.1.1-1_all_chaos_calmer.ipk
~~~~

This will install `firehol` and `fireqos` and all of their required
dependencies.

If you want to inspect traffic with FireQOS, also install `tcpdump`:

~~~~
opkg install tcpdump
~~~~

To disable the pakages (they are enabled by default but do nothing
until you put in place a configuration):

~~~~
/etc/init.d/firehol disable
/etc/init.d/fireqos disable
~~~~

### Setup FireHOL

Your configuration depends on your router setup. Be careful not to
firewall yourself out or you will find yourself using [OpenWRT failsafe
mode](http://wiki.openwrt.org/doc/howto/generic.failsafe). You can help
avoid this by editing the firewall setup in a temporary location and
running `/sbin/firehol /tmp/new-firehol.conf`{.command} which will
automatically revert after 30 seconds if you do not explicitly accept
the new configuration (impossible if you have disabled your current
connection).

The package installs a sample configuration which you can use
as a starting point:

~~~~
cp /etc/firehol/firehol.conf.example /etc/firehol/firehol.conf
~~~~

Running `/sbin/firehol start`{.command} for the first time:

~~~~ {.programoutput}
 WARNING:
 --------
 FireHOL cannot find your current kernel configuration.
 Please, either compile your kernel with /proc/config,
 or make sure there is a valid kernel config in:
 /usr/src/linux/.config
 
 Because of this, FireHOL will simply attempt to load
 all kernel modules for the services used, without
 being able to detect failures.
 
FireHOL: Saving active firewall to a temporary file...  OK 

WARNING INIT:  No saved firewall found to restore.

FireHOL: Processing file '/etc/firehol/firehol.conf'...  OK  (497 iptables rules)
FireHOL: Fast activating new firewall... module is already loaded - nf_conntrack
module is already loaded - ip6_tables
 OK 
FireHOL: Saving activated firewall to '/etc/firehol-spool'...  OK 

~~~~

The kernel warning happens because to save space OpenWRT does not store the
kernel configuration. It should not be a problem in practice; you will just
be notified that module are already loaded.

The "No saved firewall found to restore" warning is because this is the
first time FireHOL has run. In future it will check the time of the
config files and if they have not been updated it will use a cached
version of the rules to load much quicker.

When you are happy that everything is as it should be, disable the
default firewall, and enable FireHOL instead:

~~~~ {.programlisting}
/etc/init.d/firewall disable
~~~~

If you want to use the firewall on bridged interfaces, install the `physdev`
matcher:

~~~~
opkg install iptables-mod-physdev
~~~~

On versions prior to `18.06`, edit `/etc/sysctl.conf`{.filename} to enable
matching:

~~~~ {.programlisting}
net.bridge.bridge-nf-call-arptables=0
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
~~~~

Reload the configuration:

~~~~ {.programlisting}
sysctl -p
~~~~

If you choose to install `iprange` using the appropriate `iprange*.ipk` for
your platform, you can tell FireHOL to make use of it by editing
`/etc/firehol/firehol-defaults.conf`.

### Setup FireQOS

Some OpenWRT installations come only with insmod, not modprobe. Unless
you tell the kernel to use insmod to autoload modules, then `tc`, as used
by FireHOL will not work correctly.

This is done for you when you run via the init script above. If your,
system does not have modprobe, run the following so you can get your
initial setup done:

~~~~ {.programoutput}
echo "/sbin/insmod" > /proc/sys/kernel/modprobe
~~~~

If modules are not loading correctly, you will get cryptic errors such as:

~~~~ {.programoutput}
RTNETLINK answers: No such file or directory

ERROR:
tc failed with error 2, while executing the command:
/usr/sbin/tc qdisc add dev pppoe-wan-ifb root handle 1: stab linklayer adsl
overhead 40 htb default 5000 r2q 8

FAILED TO ACTIVATE TRAFFIC CONTROL.
~~~~

For some more information on kernel module loading, see
[here](http://www.tldp.org/HOWTO/Module-HOWTO/x197.html).

The package installs a sample configuration which you can use
as a starting point:

~~~~
cp /etc/firehol/fireqos.conf.example /etc/firehol/fireqos.conf
~~~~

In particular, make sure you identify your WAN interface correctly
and assign it the appropriate speeds and overheads.

Running `/sbin/fireqos start`{.command} for the first time:

~~~~ {.programoutput}
FireQOS 3.1.1
(C) 2013-2014 Costa Tsaousis, GPL


: interface eth0 world-in input adsl local pppoe-llc input rate 10370kbit output rate 845kbit (eth0-ifb, 10370kbit, mtu 1500, quantum 1500, minrate 103kbit)
: 	class voip commit 100kbit pfifo
 WARNING: 39@/etc/firehol/fireqos.conf: class:
 class rate (100kbit) was less than the interface minrate (103kbit). Fixed it by setting class rate to minrate. 

 (1:11, 103/10370kbit, prio 0)
: 	class interactive input commit 20% output commit 10% (1:12, 2074/10370kbit, prio 1)
: 	class chat input commit 1000kbit output commit 440kbit (1:13, 1000/10370kbit, prio 2)
: 	class vpns input commit 20% output commit 10% (1:14, 2074/10370kbit, prio 3)
: 	class servers (1:15, 103/10370kbit, prio 4)
: 	class surfing prio keep commit 10% (1:16, 1037/10370kbit, prio 4)
: 	class synacks (1:17, 103/10370kbit, prio 5)
: 	class default (1:8000, 103/10370kbit, prio 6)
: 	class torrents (1:19, 103/10370kbit, prio 7)
: 	committed rate 6703kbit (64%), the remaining 3666kbit will be spare bandwidth.


: interface eth0 world-out output adsl local pppoe-llc input rate 10370kbit output rate 845kbit (eth0, 845kbit, mtu 1500, quantum 1500, minrate 12kbit)
: 	class voip commit 100kbit pfifo (1:11, 100/845kbit, prio 0)
: 	class interactive input commit 20% output commit 10% (1:12, 84/845kbit, prio 1)
: 	class chat input commit 1000kbit output commit 440kbit (1:13, 440/845kbit, prio 2)
: 	class vpns input commit 20% output commit 10% (1:14, 84/845kbit, prio 3)
: 	class servers (1:15, 12/845kbit, prio 4)
: 	class surfing prio keep commit 10% (1:16, 84/845kbit, prio 4)
: 	class synacks (1:17, 12/845kbit, prio 5)
: 	class default (1:8000, 12/845kbit, prio 6)
: 	class torrents (1:19, 12/845kbit, prio 7)
: 	committed rate 840kbit (99%), the remaining 5kbit will be spare bandwidth.


  Traffic is classified:

      - on 2 interfaces
      - to 18 classes
      - by 78 FireQOS matches

  235 TC commands executed

All Done! Enjoy...
bye...
~~~~
