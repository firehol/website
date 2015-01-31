---
title: Adding Services
submenu: documentation
---

Adding Services
===============

If you intend to use a definition only once, you can consider using the
<%= html_to('custom','/keyword/service/custom') %> service.

This [Wikipedia list of
ports](http://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers)
and this [list of port names and
numbers](http://www.graffiti.com/services) may be useful when defining
your own services.

Simple Service
--------------

To define new services you add the appropriate entries before using them
later in the configuration file.

For example, consider a service named "daftnet" that listens at two
ports, port 1234 TCP and 1234 UDP where the expected client ports are
the default ports a system may choose plus the same port numbers the
server listens at, with further dynamic ports for which we have some
kernel modules which will do the tracking:

<%= include_example('adding-services-01') %>

Even though multiple ports are used in both directions, this is still a
simple service. FireHOL determines all of the combinations of client and
server ports and generates multiple iptables statements to match them.

### Required entries

The following are required for all simple services:

~~~~ {.programlisting}
server_myservice_ports="proto/sports"
client_myservice_ports="cports"
~~~~

*myservice* is the name we will give our service.

*proto* is anything that `iptables`{.command} accepts as a protocol e.g.
"tcp", "udp", "icmp" and numeric protocol values.

*sports* is the ports the server is listening at. It is a
space-separated list of port numbers, names and ranges (from:to). The
keyword *any* will match any server port.

*cports* is the ports the client may use to initiate a connection. It is
a space-separated list of port numbers, names and ranges (from:to). The
keyword *any* will match any client port. The keyword *default* will
match default client ports.

For the local machine (e.g. a client within an interface) the default
client ports resolve to sysctl variable `net.ipv4.ip_local_port_range`
(or `/proc/sys/net/ipv4/ip_local_port_range`{.filename}).

For a remote machine (e.g. a client within an interface or anything in a
router) the default client ports resolve to the variable
`DEFAULT_CLIENT_PORTS`{.var}. For more information see <%=
html_to('Control_Variables','/keyword/manref/firehol/variables-control')
%> in the manual.

### Optional entries

The following entries are optional. They are only needed if a kernel
module must be loaded to help track connections (typically because the
protocol uses dynamic ports):

~~~~ {.programlisting}
require_myservice_modules="modules"
require_myservice_nat_modules="nat-modules"
~~~~

The named kernel modules will be loaded when the definition is used. The
NAT modules will only be loaded if `FIREHOL_NAT`{.var} is non-zero (see
<%=
html_to('Control_Variables','/keyword/manref/firehol/variables-control')
%>).

Complex Service
---------------

To create more complex rules, or stateless rules, you will need to
create a bash function prefixed `rules_` e.g. `rules_myservice`.
The best reference is the many such functions in the main firehol
script.

Adding your service to "all"
----------------------------

When adding a service with a custom function or which uses modules, you
may also wish to include the following:

~~~~ {.programlisting}
ALL_SHOULD_ALSO_RUN="${ALL_SHOULD_ALSO_RUN} myservice"
~~~~

which will ensure your service is set-up correctly as part of the all
service. There is no need to do this with simple services which do not
load modules.

Creating your service in a separate file
----------------------------------------

To allow definitions to be shared you can create files and install them
in the `/etc/firehol/services`{.filename} directory with a
`.conf`{.filename} extension.

The first line must read:

~~~~ {.programlisting}
#FHVER: 1:213
~~~~

1 is the service definition API version. It will be changed if the API
is ever modified. The 213 originally referred to a FireHOL 1.x minor
version but is no longer checked.

FireHOL will refuse to run if the API version does not match the
expected one.
