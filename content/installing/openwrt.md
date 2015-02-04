---
title: OpenWRT installation
submenu: downloads
---

Installation on OpenWRT
=======================

There is no package but you can easily install and run FireHOL and
FireQOS on [OpenWRT](https://openwrt.org/). The only problem you will
encounter is the Bash binary is quite large, so needs a device with a
reasonable amount of storage.

I have been running FireHOL on an unmodified v1.5 [TP-Link
TL-WR1043ND](http://wiki.openwrt.org/toh/tp-link/tl-wr1043nd) without
trouble for a couple of years. This device has 32MB RAM and 8MB flash.

These instructions are for Attitude Adjustment (12.09) which FireQOS
requires. FireHOL will also run on Backfire (10.03) but you will need to
adapt the instructions slightly.

### FireHOL

On the router:

~~~~ {.programlisting}
mkdir -p /etc/firehol/services
opkg update
opkg install bash
opkg install coreutils-fold
opkg install flock
opkg install iptables-mod-extra
opkg install iptables-mod-conntrack-extra
opkg install iptables-mod-ipopt
opkg install kmod-ipt-nathelper-extra
~~~~

I will assume you want IPv6, so ensure the appropriate bits are present:

~~~~ {.programlisting}
opkg install kmod-ip6tables
opkg install ip6tables
~~~~

Since we have not yet configured FireHOL, we must update the default
ruleset to protect your installation: `fw restart`{.command}. The
OpenWRT wiki has more information on [IPv6 in
OpenWRT](http://wiki.openwrt.org/doc/howto/ipv6).

OpenWRT is too lightweight to be worth running the configure script, so
from my host I just copied up the files:

~~~~ {.programlisting}
scp sbin/firehol.in root@router:/sbin/firehol
scp openwrt-firehol.init root@router:/etc/init.d/firehol
scp openwrt-firehol.conf root@router:/etc/firehol/firehol.conf
~~~~

The init script is this:

~~~~ {.programlisting}
#!/bin/sh /etc/rc.common

# The OpenWRT system uses this to determine start order for links to
# create in /etc/rc.d when you run e.g. /etc/init.d/firehol enable
START=45

# To create some saved files for early loading, run:
#   export FIREHOL_AUTOSAVE=/etc/firehol/saved.iptables
#   export FIREHOL_AUTOSAVE6=/etc/firehol/saved.ip6tables
#   /sbin/firehol save

start() {
  # We rely on the lockfile being on ephemeral storage; it is always gone
  # after a reboot and always present after a first run of firehol
  lock=/tmp/run/firehol.lck
  saved=/etc/firehol/saved
  if [ -x /usr/sbin/iptables-restore -a -f $saved.iptables -a ! -f $lock ]
  then
    echo "First, restoring saved $saved.iptables"
    /usr/sbin/iptables-restore $saved.iptables
  fi
  if [ -x /usr/sbin/ip6tables-restore -a -f $saved.ip6tables -a ! -f $lock ]
  then
    echo "First, restoring saved $saved.ip6tables"                          
    /usr/sbin/ip6tables-restore $saved.ip6tables                            
  fi                                                                        
  /sbin/firehol start                                                       
}                                                                           
                                                                            
restart() {                                                                 
  /sbin/firehol start                                                       
}                                                                           
                                                                            
reload() {                                                                  
  /sbin/firehol start                                                       
}                                                 
~~~~

Your configuration depends on your router setup. Be careful not to
firewall yourself out or you will find yourself using [OpenWRT failsafe
mode](http://wiki.openwrt.org/doc/howto/generic.failsafe). You can help
avoid this by editing the firewall setup in a temporary location and
running `/sbin/firehol /tmp/new-firehol.conf`{.command} which will
automatically revert after 30 seconds if you do not explicitly accept
the new configuration (impossible if you have disabled your current
connection).

This is roughly my config:

<%= include_example('openwrt-01') %>

Running `/sbin/firehol start`{.command} for the first time:

~~~~ {.programoutput}
 
 IMPORTANT WARNING:
 ------------------
 FireHOL cannot find your current kernel configuration.
 Please, either compile your kernel with /proc/config,
 or make sure there is a valid kernel config in:
 /usr/src/linux/.config
 
 Because of this, FireHOL will simply attempt to load
 all kernel modules for the services used, without
 being able to detect failures.
 
FireHOL: Saving your old firewall to a temporary file: OK
FireHOL: Processing file /etc/firehol/firehol.conf: OK
FireHOL: Activating new firewall (571 rules): OK
~~~~

The warning happens because to save space OpenWRT does not store the
kernel configuration. Provided you have installed all the modules
correctly you should not have any problems.

On my router, without fast activation, this takes 118 seconds. With
`FIREHOL_FAST_ACTIVATION=1` in the config, it takes 95 seconds but
importantly almost all of them are spent calculating the firewall, the
activation (replacing existing firewall) is less than 5 seconds.

The init script will load `/etc/firehol/saved.iptables`{.filename} and
`/etc/firehol/saved.ip6tables`{.filename} before running
`/sbin/firehol`{.filename}, if they are present. They can be created by
running this:

~~~~ {.programlisting}
export FIREHOL_AUTOSAVE=/etc/firehol/saved.iptables
export FIREHOL_AUTOSAVE6=/etc/firehol/saved.ip6tables
/sbin/firehol save
~~~~

These files are not required for correct operation but ensure some kind
of firewall is in place very quickly after a reboot. Any config will do
provided that you know it will allow you to access the device yet
protect your network if you break your firehol.conf file and reboot
before realising.

When you are happy that everything is as it should be, disable the
default firewall, and enable FireHOL instead:

~~~~ {.programlisting}
/etc/init.d/firewall disable
/etc/init.d/firehol enable
~~~~

To check the link was created: `ls -l /etc/rc.d/S45firehol`{.command}
should point to the correct init file.

If you want to use the firewall on bridged interfaces, edit
`/etc/sysctl.conf`{.filename} to enable it:

~~~~ {.programlisting}
net.bridge.bridge-nf-call-arptables=0
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
~~~~

and reload the configuration:

~~~~ {.programlisting}
sysctl -p
~~~~

### FireQOS

This section assumes you have already installed FireHOL. If not you
should run the initial `mkdir`{.command} and `opkg`{.command}
installation commands as a minimum.

On the router:

~~~~ {.programlisting}
opkg install tc
opkg install ip
opkg install tcpdump
opkg install kmod-ifb
opkg install kmod-sched
opkg install kmod-dummy
~~~~

Copying up files from the host:

~~~~ {.programlisting}
scp sbin/fireqos.in border:/sbin/fireqos
scp openwrt-fireqos.init root@router:/etc/init.d/fireqos
scp openwrt-fireqos.conf root@router:/etc/firehol/fireqos.conf
~~~~

The init script is this:

~~~~ {.programlisting}
#!/bin/sh /etc/rc.common

# The OpenWRT system uses this to determine start order for links to
# create in /etc/rc.d when you run e.g. /etc/init.d/fireqos enable
START=46

start() {
  if [ -x /sbin/insmod -a ! -x /sbin/modprobe ]
  then
    echo "/sbin/insmod" > /proc/sys/kernel/modprobe
  fi
  /sbin/fireqos start
}

restart() {
  /sbin/fireqos start
}

reload() {
  /sbin/fireqos start
}

stop() {
  /sbin/fireqos stop
}
~~~~

OpenWRT lacks the `modprobe`{.command} command. FireQOS is able to deal
with this by using `insmod`{.command} instead.

The `tc`{.command} command that FireQOS uses to setup traffic control
communicates with the kernel using RTNETLINK. The kernel then tries to
autoload more modules. By default it tries to do this with modprobe. If
it is not able to do so, you will get cryptic errors such as:

~~~~ {.programoutput}
RTNETLINK answers: No such file or directory

ERROR:
tc failed with error 2, while executing the command:
/usr/sbin/tc qdisc add dev pppoe-wan-ifb root handle 1: stab linklayer adsl
overhead 40 htb default 5000 r2q 8

FAILED TO ACTIVATE TRAFFIC CONTROL.
~~~~

If you see such an error, the first thing to do is check if you have
`/sbin/modprobe`{.filename}, and if you do not, to tell the kernel to
use `insmod`{.command} to autoload modules:

~~~~ {.programoutput}
echo "/sbin/insmod" > /proc/sys/kernel/modprobe
~~~~

This is done for you if you run via the init script above. For some more
information on kernel module loading, see
[here](http://www.tldp.org/HOWTO/Module-HOWTO/x197.html).

This is roughly my config (public is my open wifi for anyone, but my
data limits are quite low, so I limit it heavily):

<%= include_example('openwrt-qos-01') %>

Running `/sbin/fireqos start`{.command} for the first time:

~~~~ {.programoutput}
FireQOS $Id: 41004cd0a5f6c3a3bfa0beb67c3bdcb2ecf1a3fe $
(C) 2013 Costa Tsaousis, GPL


: interface pppoe-wan world-in input rate 10500kbit adsl local pppoe-llc
mtu 1492 (pppoe-wan-ifb, MTU 1492, quantum 1492)
:       class public rate 5% ceil 5% (1:11, 525kbit, prio 0)
:       class interactive commit 20% (1:12, 2100kbit, prio 1)
:       class facetime commit 200kbit (1:13, 200kbit, prio 2)
:       class vpns commit 20% (1:14, 2100kbit, prio 3)
:       class surfing commit 30% (1:15, 3150kbit, prio 4)
:       class synacks (1:16, 105kbit, prio 5)
:       class default (1:5000, 105kbit, prio 6)
:       class torrents (1:18, 105kbit, prio 7)
:       committed rate 8390kbit (79%), the remaining 2110kbit will be spare
bandwidth.

: interface pppoe-wan world-out output rate 819kbit adsl local pppoe-llc
mtu 1492 (pppoe-wan, MTU 1492, quantum 1492)
:       class public rate 5% ceil 5% (1:11, 40kbit, prio 0)
:       class interactive commit 20% (1:12, 163kbit, prio 1)
:       class facetime commit 200kbit (1:13, 200kbit, prio 2)
:       class vpns commit 20% (1:14, 163kbit, prio 3)
:       class surfing commit 5% (1:15, 40kbit, prio 4)
:       class synacks (1:16, 11kbit, prio 5)
:       class default (1:5000, 11kbit, prio 6)
:       class torrents (1:18, 11kbit, prio 7)
:       committed rate 645kbit (78%), the remaining 173kbit will be spare
bandwidth.


All Done!. Enjoy...
bye...
~~~~

Now enable FireQOS at boot:

~~~~ {.programlisting}
/etc/init.d/fireqos enable
~~~~

To check the link was created: `ls -l /etc/rc.d/S46fireqos`{.command}
should point to the correct init file.
