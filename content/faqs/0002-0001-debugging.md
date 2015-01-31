---
group: 0002-Running
title: 0001-How do I debug my configuration?
id: debugging
kind: faq
---

If you want to investigate why some traffic is being blocked, the best
place to start may be with the [troubleshooting
guide](/guides/firehol-troubleshooting/).

To get a listing of the actions FireHOL would take based on your
configuration, you can run:

~~~~ {.programlisting}
firehol debug
~~~~

In the event of an unexpected problem, FireHOL will leave behind its
temporary files (and let you know where they are located) in order to
help you diagnose the problem.

FireHOL runs as a bash script so if you need detailed information about
what is going on internally you can add these lines to your
configuration:

~~~~ {.programlisting}
set -x
set -v
~~~~
