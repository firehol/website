---
group: 0002-Running
title: 0004-I really need help designing the configuration. Could you help?
id: configuring
kind: faq
---

To get a configuration file quickly, you can run:

~~~~ {.programlisting}
firehol helpme
~~~~

The <%= html_to('helpme_feature','/keyword/manref/firehol/helpme')
%> reads various system parameters of your system and generates a
configuration file especially for the host it runs. Helpme is safe to
use: it does not alter your running firewall, it does not modify
anything on your system.

In general, I will try to avoid helping you on manual configuring your
specific firewall; I commit however to making helpme detect correctly
every single case. I believe, this will benefit all the community, not
just you.

In any case, I guess I have done a good job in designing FireHOL the way
you expect it to work, and that the documentation is helpful enough,
since all the support tools are pretty silent. Of course you are welcome
to ask anything you might need regarding FireHOL.
