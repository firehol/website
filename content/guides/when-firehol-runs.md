---
title: When FireHOL Runs
submenu: documentation
---

When FireHOL Runs
=================

FireHOL is a [Bash](http://www.gnu.org/software/bash/bash.html) script.
To run its configuration file, FireHOL first defines a set of functions
and variables and then it "sources" (runs inline) its configuration file
to be executed by [BASH](http://www.gnu.org/software/bash/bash.html).

The keywords <%= html_to('interface','/keyword/firehol/interface')
%>, <%= html_to('client','/keyword/firehol/client') %>, <%=
html_to('server','/keyword/firehol/server') %>, <%=
html_to('router','/keyword/firehol/router') %>, etc. are all
[BASH](http://www.gnu.org/software/bash/bash.html) functions that are
executed by [BASH](http://www.gnu.org/software/bash/bash.html) when and
if they appear in the configuration file. Using shared variables these
functions share some state information that allows them to know, for
example, that a <%= html_to('client','/keyword/firehol/client') %>
command appears within an <%=
html_to('interface','/keyword/firehol/interface') %> and not within a
<%= html_to('router','/keyword/firehol/router') %> and that the name
given to an <%= html_to('interface','/keyword/firehol/interface') %>
that has not been used before.

Instead of running iptables commands directly, each of these functions
(i.e. FireHOL) just writes the generated iptables commands to a
temporary file. This is done to prevent altering a running firewall
before ensuring that the syntax of the configuration file is correct.
So, a complete run of the configuration file actually produces all the
iptables commands for the firewall, written to a temporary file
(script). Even the [iptables](http://www.netfilter.org/) commands given
within the configuration file use the same concept (they just generate
iptables commands in this script).

Finally, this script (the generated iptables commands) has to be run,
but before doing so, FireHOL saves the running firewall to another
temporary file. The saved firewall will be automatically restored if
some of the generated iptables commands produces an error. Such an error
is possible when for example, you specify an invalid IP address or
hostname, or an invalid argument to some parameter that gets passed to
iptables as-is.

It is important to understand that **by default, during the run
of the generated iptables script** (including the possible
restoration of the old firewall), **FireHOL allows all traffic
to reach its destination**.

This has been done to **prevent a possible lock-out** situation where
you are SSHing to the server to alter its firewall, and suddenly
you loose the connection. To **control this behaviour**, set the <%=
html_to('ACTIVATION_variables','/keyword/manref/firehol/variables-activation')
%>.

Note you can still can lock yourself out if your new firewall doesn't
allow the connection. To prevent accidents when updating remote
firewalls consider using the [try](/firehol-manual/firehol/)
command to start the firewall.

If no error has been seen, FireHOL deletes all temporary files generated
and exits.

In case there was an error, FireHOL will make the most to restore your
previous firewall and will present you details about the error and its
line number in the original configuration file.
