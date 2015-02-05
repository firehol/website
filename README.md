FireHOL Website
===============

This tree contains the sources for the FireHOL website:
    http://firehol.org

The website is built using nanoc, pandoc and nokogiri. If you have ruby 1.9+
(on your machine you can install them with gem:

    sudo gem install nanoc pandoc-ruby nokogiri

Note: building pandoc-ruby and nokogiri requires you to have installed
the ruby headers (e.g. ruby1.9.1-dev Ubuntu 12.04 and ruby-dev on
Debian Wheezy).

To be able to preview the site with a mini web-server, also install adsf:

    sudo gem install adsf

More comprehensive install instructions for nanoc are here:

    <http://nanoc.ws/install/>


Building the site locally
-------------------------

    make

This will try to import the manual pages from the firehol package
(you may need to update the locations variable) and build the HTML
output.


Viewing the site locally
------------------------
To view via a mini web server, run:

    nanoc view

which makes the site available at:

    <http://localhost:3000/>

Or, just point your browser to output/index.html once the site has
been built.


Working in markdown
-------------------
To create a page:

    http://site/mypage

The filename reflects the URL directly, unless there is special processing
in the [Rules](#special-rules) file (faqs and man examples, testimonies and
newsitems directories). Therefore just create a file:

    content/mypage.md

Adding the item to the site menu is just a matter of including a list
item with a link in layouts/default.html in the `sidebar` div.

The beginning of the file is a nanoc header delimited by `---` and
should include a title (becomes the HTML title) and submenu (which causes
the menu item in question to be marked open for this page):

    ---
    title: My New Page
    submenu: mymenu
    ---

See [nanoc header](#nanoc-header) for more information.

After the second `---` just add normal markdown. The site is interpreted with
pandoc <http://johnmacfarlane.net/pandoc/README.html#pandocs-markdown> and
uses a couple of its extensions.

An erb filter is applied before any further processing, so it is possible
to embed ruby code to print variables and use flow control. This also allows
examples to be stored under content/examples and embedded with the
include_example() function as well as writing them within the file.
See [adding an external example](#adding-an-external-example).

For instance:

    # My New Page

    Some text

or:

    My New Page
    ===========

    <% if some_condition  %>
    Include this text
    <% end  %>

    Here is an embedded example:

    <%= include_example("name-in-example-header") %>

    *   Examples in a list need to understand the indentation level

        <%= include_example("name-in-example-header", "    ") %>

        Or the output will not work as expected

    Here is an inline example which will be highlighted/linked for FireHOL:

    ~~~~ {.firehol}
    firehol configuration
    ....
    ~~~~

    For FireQOS:

    ~~~~ {.fireqos}
    fireqos configuration
    ....
    ~~~~

Examples are automatically marked up with links to the manual for keywords.
To manually link to a keyword or service, just write something like:

    [src parameter](/keyword/firehol/src)

See [special rules](#special-rules) for more detail.


Working in HTML
---------------
The preferred format for pages is markdown, however if you need special
processing it is also possible to add an HTML page. The rules are very
similar to [markdown](#working-in-markdown).

To create a page:

    http://site/mypage

Create a file:

    content/mypage.html

With a [nanoc header](#nanoc-header) and insert the item in the menus
in default/layout.html.

After the second `---` of the nanoc header, just add normal HTML. This
will be embedded in the template so you can start with an `h1` and go
from there.

The erb filter is applied before any further processing, so it is possible
to embed ruby code to print variables and use flow control. This also allows
examples to be stored under content/examples and embedded with the
include_example() function as well as writing them within the file.
See [adding an external example](#adding-an-external-example).

For instance:

    <h1>My New Page</h1>

    <% if some_condition  %>
    <p>Some conditional text</p>
    <% end  %>

    Here is an embedded example:

    <%= include_example("name-in-example-header") %>

    <p>Here is an inline example which will be highlighted/linked
    for FireHOL:</p>

    <pre class="firehol"><code>
    firehol configuration
    </code></pre>

    <p>For FireQOS:</p>

    <pre class="fireqos"><code>
    fireqos configuration
    </code></pre>

Examples are automatically marked up with links to the manual for keywords.
To manually link to a keyword or service, just write something like:

    <a href="/keyword/firehol/src">src parameter</a>

See [special rules](#special-rules) for more detail.

Nanoc Header
------------

All files under content/ should start with a nanoc header, such as this:

    ---
    title: My New Page
    submenu: mymenu
    ---

Items between the --- are variables that get substituted into a template
at points labelled <%= item[:variablename] %> or used for other processing.

For example:
       title -  HTML page title (as displayed at the top of a browser window)
     submenu -  if your page is in the site menu, add the appropriate submenu
                name so it is automatically expanded, otherwise omit it
 description -  HTML meta description (a default is used if none is given)
    keywords -  HTML meta keywords (a default list is used if none is given)

When page bodies are emitted, they are wrapped in a template (at the
line <%= yield %>):

    layouts/default.html


Adding an external example
--------------------------
Examples can be embedded directly into markdown and HTML files. They can
also be extracted into a separate folder so they can be re-used across
pages.

To do this, add a file under content/examples/ and start it with a
customised [nanoc header](#nanoc-header):

    ---
    name: some-name
    kind: example
    keyword: fireqos
    ---

The kind must identify the file as an example. The name should not contain
spaces and is used to refer to the example in other pages. The keyword
value can be either *firehol* for *fireqos* and determines the type of
syntax highlighting to use.

To include and automatically format an example in another page, add it thus:

    <%= include_example("some-name") %>

Use <span class="newcode">...</span> to wrap lines in an example that
should be highlighted within this particular example, e.g. they are
additions compared to a prior example.

Special Rules
-------------
The following paths (both in url and under the `contents/` directory
have special rules and do not get generated directly into the output
site:

- /examples/    - Used to manage re-usable examples for inclusion elsewhere
- /faqs/        - Used to manage Frequently Asked Questions one per file
- /testimonies/ - Used to manage testimonials one per file
- /newsitems/   - Used to manage news items one per file
- /keyword/     - Used to link to *real* manual pages

Simply create an appropriate file with the appropriate header and the
site compilation takes care of the rest.

The /keyword/ URLs are not defined as files anywhere: the values are
extracted from the FireHOL/FireQOS reference manual during site
compilation. The URLS are checked for validity and replaced automatically
with the correct URL for within the manual.

To link to keywords in the manual, use URLs such as:

    /keyword/firehol/src

In the form /keyword/product/keyword with an optional /disambiguator at the
end (e.g. prio is used in both class and match in FireQOS). The complete
list for FireHOL:

    /keyword/firehol/mac/helper
    /keyword/firehol/mac/param
    /keyword/firehol/dscp/helper
    /keyword/firehol/dscp/param
    /keyword/firehol/mark/helper
    /keyword/firehol/mark/param
    /keyword/firehol/tos/helper
    /keyword/firehol/tos/param

The list for FireQOS:

    /keyword/fireqos/class/definition
    /keyword/fireqos/class/param
    /keyword/fireqos/prio/match
    /keyword/fireqos/prio/class
    /keyword/fireqos/priority/match
    /keyword/fireqos/priority/class

The same system works for FireHOL services, e.g.:

    /keyword/service/icmp
    /keyword/service/ssh
    ...

Other references to the manual are created as:

    /keyword/manref/whatever...

Near the top of `lib/keyword-url.rb` is a list of all such mappings,
generated by calls to replace_link(). This is the correct place to add
new references to the manual, to ensure they are cross-checked at compile
time.

Link checking
-------------

````
make
nanoc view
./run-linkchecker
firefox linkchecker-out.html
````

Deployment
----------
For deployment under nginx, see the configuration files in the
firehol-infrastructure repository.

If you have commit access to the official repositories, your changes
will be published automatically once they are pushed.
