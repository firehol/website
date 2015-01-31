---
title: Advanced Language Features
submenu: documentation
---

Advanced Language Features
==========================

<%=
html_to('FireHOL_configuration_files','/keyword/manref/firehol/config-file')
%> are normal [Bash](http://www.gnu.org/software/bash/bash.html)
scripts. As such, you can use all
[Bash](http://www.gnu.org/software/bash/bash.html) features within
FireHOL configuration files, including functions, loops, variables, I/O,
etc.

Bash is used as the base configuration language for FireHOL since it is
the common denominator for a language that all UNIX system
administrators and developers should know and understand.

The fact that FireHOL uses Bash for its configuration, allows
development of add-ons and enables FireHOL to use programs to access SQL
databases, directory structures, DBM or other files, web front ends or
other means for the rules of the firewall.

What to avoid
-------------

The only [Bash](http://www.gnu.org/software/bash/bash.html) commands a
FireHOL configuration should never use are **trap** and **exit**.

Traps are used by FireHOL for cleaning up all temporary files, and
possibly restoring the previously running firewall in case FireHOL
execution breaks, and the exit command will not just exit the
configuration file, it will exit FireHOL. FireHOL has disabled these
features by default, so that you will not be able to use them, unless
you specifically enable them.

Since a FireHOL configuration script runs inline with FireHOL, all
variables and function names defined within the configuration file
overwrite the ones defined by FireHOL so you should avoid some names.

Avoid using variables that start with **FIREHOL**, **work**,
**server**, and **client** as many such variables are used by
FireHOL internally.

There are also a number of functions names you should avoid, but there
is no generic pattern at the moment. I suggest you should avoid defining
functions with the names of FireHOL commands (interface, router, client,
server, etc) and functions starting with **rules**.

Note however that you may wish to overwrite a few variables and
functions if you want to modify FireHOL services. See the [Adding
Services](/guides/adding-services/) guide for details.

Learning Bash
-------------

To learn [Bash](http://www.gnu.org/software/bash/bash.html) scripting I
suggest the following documents:

-   [Advanced Bash-Scripting
    Guide](http://www.tldp.org/LDP/abs/html/index.html)
-   [Bash Programming - Introduction
    HOW-TO](http://www.tldp.org/HOWTO/Bash-Prog-Intro-HOWTO.html)
    (older)

