---
title: OpenWRT installation
submenu: downloads
---

Installation on OpenWRT prior to Chaos Calmer (15.05)
=====================================================

There is no package but you can easily install and run FireHOL and
FireQOS on [OpenWRT](https://openwrt.org/). The only problem you will
encounter is the Bash binary is quite large, so needs a device with a
reasonable amount of storage.

I have been running FireHOL on an unmodified v1.5 [TP-Link
TL-WR1043ND](http://wiki.openwrt.org/toh/tp-link/tl-wr1043nd) without
trouble for a couple of years. This device has 32MB RAM and 8MB flash.

These instructions are for Barrier Breaker (14.07) which FireQOS requires.
FireHOL will also run on Attitude Adjustment (12.09) and Backfire (10.03)
but you might need to adapt the instructions slightly.

This guide skips link-balancer because it requires a package for iprange
which must be compiled to binary, which is much more complex. Also skipped
are vnetbuild and update-ipsets, since they are not really aimed at router
use.

We will assume that your router's hostname is `openwrt` throughout this
document.

### Preparation

On the router, ensure your clock is set correctly, and if not update it:

~~~~
ssh root@openwrt
date -s "YYYY-MM-DD hh:mm:ss"
~~~~

Install required packages for FireHOL:

~~~~ {.programlisting}
opkg update
opkg install bash
opkg install coreutils-fold
opkg install flock
opkg install grep
opkg install make
opkg install iptables-mod-extra
opkg install iptables-mod-conntrack-extra
opkg install iptables-mod-ipopt
opkg install kmod-ipt-nathelper-extra
~~~~

Note: prior to Barrier Breaker you needed to explicitly enable IPv6.

If you want to install FireQOS, also add these:

~~~~ {.programlisting}
opkg install tc
opkg install ip
opkg install tcpdump
opkg install kmod-ifb
opkg install kmod-sched
opkg install kmod-dummy
~~~~

### Copy and unpack package

We will use the standard tar-file from the website.

Some versions of [busybox tar have a bug](https://dev.openwrt.org/ticket/20660)
which you may hit, so if you see a message `invalid tar magic` during the
tar step, you will need to use the alternate method presented afterwards:

Copy up and unpack the tar-file:

~~~~ {.programlisting}
scp firehol-3.x.y.tar.gz root@openwrt:/tmp
ssh root@openwrt
cd /tmp
tar -zxvf firehol-3.x.y.tar.gz
~~~~

Alternate method, if tar does not work
:   Unpack locally and copy up:

    ~~~~ {.programlisting}
    tar xvfz firehol-3.x.y.tar.gz
    scp -rp firehol-3.x.y root@openwrt:/tmp
    ~~~~

# Configure and install

Run configure as follows (add `--disable-fireqos` if you only want FireHOL):

~~~~
ssh root@openwrt
cd /tmp/firehol-3.x.y
./configure --disable-doc --disable-man --disable-firehol-wizard \
   --disable-link-balancer --disable-vnetbuild --disable-update-ipsets \
   --prefix=/usr --sbindir=/sbin --sysconfdir=/etc \
   --localstatedir=/var --libexecdir=/usr/lib
~~~~

You can choose to leave the FireHOL wizard enabled but you will likely need
to install some more openwrt packages if you do.

Install with `make`:

~~~~ {.programlisting}
make install
~~~~

Add an OpenWRT init script for FireHOL:

~~~~ {.programlisting}
cat - > /etc/init.d/firehol <<_END_
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
_END_
chmod 755 /etc/init.d/firehol
~~~~

Add an OpenWRT init script for FireQOS:

~~~~ {.programlisting}
cat - > /etc/init.d/fireqos <<_END_
#!/bin/sh /etc/rc.common

# The OpenWRT system uses this to determine start order for links to
# create in /etc/rc.d when you run e.g. /etc/init.d/fireqos enable
START=46

start() {
  # Some OpenWRT have insmod and not modprobe. FireQOS will work fine provided
  # we tell the kernel that it should be using insmod.
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
_END_
chmod 755 /etc/init.d/fireqos
~~~~


# Setup FireHOL

Your configuration depends on your router setup. Be careful not to
firewall yourself out or you will find yourself using [OpenWRT failsafe
mode](http://wiki.openwrt.org/doc/howto/generic.failsafe). You can help
avoid this by editing the firewall setup in a temporary location and
running `/sbin/firehol /tmp/new-firehol.conf`{.command} which will
automatically revert after 30 seconds if you do not explicitly accept
the new configuration (impossible if you have disabled your current
connection).

My configurations are roughly as follows:

* [/etc/firehol/firehol-defaults.conf](/files/installing-openwrt/firehol-defaults.conf)
* [/etc/firehol/firehol.conf](/files/installing-openwrt/firehol.conf)

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
protect your network if you break your `firehol.conf` file and reboot
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

My configurations is roughly as follows:

* [/etc/firehol/fireqos.conf](/files/installing-openwrt/fireqos.conf)

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

To enable FireQOS at boot:

~~~~ {.programlisting}
/etc/init.d/fireqos enable
~~~~

To check the link was created: `ls -l /etc/rc.d/S46fireqos`{.command}
should point to the correct init file.
