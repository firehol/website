---
title: FireHOL support for ipset
submenu: documentation
---

# FireHOL support for ipset

`ipset` is command line utility that allows the firewall admins to manage large lists of IPs.

`ipset` is independent of `iptables`. Once a collection of IPs has been created with `ipset`, `iptables` and FireHOL can use it. Adding or removing IPs to/from the collection, does not need any change at the firewall. Collections are manipulated by the ipset command and the firewall will automatically use the new IPs.

An `ipset` collection is defined by its name. To create an new collection run on a shell:

```sh
ipset create NAME hash:ip
```

- `NAME` is the name of the collection.
- `hash:ip` is the method of storing and searching the collection. Mainly 2 types are used: `hash:ip` for a collection of individual IPs and `hash:net` for a collection of networks. The difference is how efficient the storage of the collection will be and how fast the kernel will search in the collection for matching packets.

To see the active collections, run:

```sh
ipset list -n
```

`-n` is required to show just the names. Without it, `ipset` will also dump the entire collection.

To add IPs to our collection, run:

```sh
ipset add NAME 1.2.3.4
```

to delete IPs from our collection, run:

```sh
ipset del NAME 1.2.3.4
```

Check the manual page of `ipset` for more information.

---

FireHOL support for `ipset` has two aspects:

## Matching ipset collections in FireHOL rules

FireHOL can use ipset collections for matching packets in all its statements. They are part of the `src` and `dst` keywords. For example, to allow smtp requests from all the clients in a collection, use:

```sh
server smtp accept src ipset:NAME
```

To all the servers IPs of a collection:

```sh
server smtp accept dst ipset:NAME
```

Matching both clients' and servers' IPs is also possible:

```sh
server smtp accept src ipset:NAME dst ipset:NAME
```

You can actually use `ipset:NAME` like an IP, in all statements:

```sh
blacklist full ipset:BADGUYS
...
transparent_squid 3128 "root squid proxy" inface eth0 \
         src ipset:mylans \
         dst not ipset:servers_that_dont_like_proxies
...
mark 1 OUTPUT dst "ipset:NAME 1.2.3.4"
...
server smtp accept src "1.2.3.4 ipset:NAME1 ipset:NAME2" \
                   dst not "ipset:NAME3 5.6.7.8 ipset:NAME4 10.1.2.3"
```

The good thing about `ipset` is that you can manipulate the IPs without restarting the firewall. Just add or remove IPs or networks with the `ipset` command, and immediately the firewall will use the new IPs.

The bad thing is that the `ipset` collection must exist before activating the firewall. This is why FireHOL can initialize the `ipset` collections for you:

## Defining ipset collections in FireHOL

FireHOL has an `ipset` helper. It is a wrapper around the real `ipset` command and is handled internally within FireHOL in such a way so that the ipset collections defined in the configuration will be activated before activating the firewall.

FireHOL is also smart enough to restore the ipsets after a reboot, before it restores the firewall, so that everything will work as seamlessly as possible.

The `ipset` helper has the same syntax with the real `ipset` command. So in FireHOL you just add the `ipset` statements you need, and FireHOL will do the rest.

Keep in mind that each `ipset` collection is either IPv4 or IPv6. In FireHOL prefix `ipset` with either `ipv4` or `ipv6` and FireHOL will choose the right IP version.

The FireHOL helper also allows mass import of ipset collections from files. This is done with `ipset addfile` command. This command is only supported from within `firehol.conf`. It will not work on your terminal.

The `ipset addfile` command will get a filename, remove all comments (anything after a `#` on the same line), trim any empty lines and spaces, and add all the remaining lines to `ipset`, as if each line of the file was run as `ipset add COLLECTION_NAME IP_FROM_FILE [other options]`.

The syntax of the `ipset addfile` command is:

```sh
ipset addfile COLLECTION_NAME [ip|net] filename [other ipset add options]
```

- `COLLECTION_NAME` is the collection to add the IPs
- `ip` will select all the lines of the file that do not contain a `/`
- `net` will select all the lines of the file that contain a `/`
- `filename` is the filename to read. You can give relative filenames to `/etc/firehol`
- `other ipset add options` is whatever else `ipset add` support that you are willing to give for each line

Example in `firehol.conf`
```sh
ipv4 ipset create badguys hash:ip
ipv4 ipset add badguys 1.2.3.4
ipv4 ipset addfile badguys file-with-the-bad-guys-ips.txt

...

ipv4 blacklist full ipset:badguys

```

The `ipset add` command implemented in FireHOL also allows you to give multiple IPs separated by comma or enclosed in quotes and separated by space. This will also not work on your terminal.

```sh
ipv4 ipset create badguys hash:ip
ipv4 ipset add badguys 1.2.3.4,5.6.7.8,9.10.11.12 # << comma separated
ipv4 ipset add badguys "11.22.33.44 55.66.77.88"  # << space separated in quotes
```


## Real life example

The url http://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt contains a list of IPs that we would like to block.

Get this file to `/etc/firehol/` with:

```sh
cd /etc/firehol
wget "http://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt"
```

open `/etc/firehol/firehol.conf` and add these:

```sh
# one collection for the single IPs
ipv4 ipset create emerging_block_ips hash:ip
ipv4 ipset addfile emerging_block_ips ips emerging-Block-IPs.txt

# another collection for the networks
ipv4 ipset create emerging_block_nets hash:net
ipv4 ipset addfile emerging_block_nets nets emerging-Block-IPs.txt

# blacklist them
ipv4 blacklist full ipset:emerging_block_ips ipset:emerging_block_nets
```

Now, create a small script to update it daily:

```sh
#!/bin/bash

tmp=$(mktemp) || exit 1
wget -O $tmp "http://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt"
if [ $? -ne 0 -o ! -s $tmp ]
then
    rm $tmp
    echo >&2 "Cannot download blacklist."
    exit 1
fi

# update the ipsets
firehol ipset_update_from_file emerging_block_ips ips $tmp
firehol ipset_update_from_file emerging_block_nets nets $tmp
rm $tmp

```

As you can see we called FireHOL, but this just updates the IPs in the ipsets. It does not touch the firewall.
After the `ipset_update_from_file` parameter, FireHOL accepts everything `ipset addfile` accepts.
