================
logstash formula
================

Install and configure Logstash for Debian and RedHat based systems using
pillar data.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``logstash``
------------

Install the ``logstash`` package, set up input/filter/output configuration
files, and enable the service.  Compatible only with Salt 2014.1.10+, due to
requirement for "mapping" test in jinja 2.6.

Usage
=====

See pillar.example for an example configuration.

Basic Usage
-----------

The pillar data is structured as a dictionary with key 'logstash', followed
by three optional keys:

* inputs: A list of input plugins, to be rendered in-order to 
  /etc/logstash/conf.d/01-inputs.conf
* filters: A list of filter plugins, to be rendered in-order to 
  /etc/logstash/conf.d/02-filters.conf
* outputs: A list of output plugins, to be rendered in-order to 
  /etc/logstash/conf.d/03-outputs.conf

Each list item for any of the three plugin types contains arbitrary
attributes of type string, number, dictionary, or list which will 
be rendered into Logstash's configuration syntax.  For a list of plugins
and their configuration attributes,see <http://logstash.net/docs/1.4.2/>.

Using Conditionals
------------------
The only plugin attributes that are unique for this formula is the "cond" 
attribute, which is used to set up conditionals.  For example you may want
to filter a logstash entry only if it meets certain criteria, such as being of
a certain type.  This formula supports if/else if/else by embedding the 
conditional to be used in the "cond" attribute of the plugin.  For this reason,
this formula does not support nested conditionals at this time.  See
pillar.example for an example of the conditional functionality.

Overriding Defaults
-------------------
This formula sets up certain defaults in map.jinja, specifically:

* Name of the logstash package is logstash
* Name of the logstash service is logstash
* The latest version of logstash available will be installed (pkg.latest 
 and kept up to date, instead of a one-time install of the latest version
 (e.g. use states.pkg.latest instead of states.pkg.installed)
* The configuration files will use an indentation of four spaces

These settings can be overridden by adding the appropriate keys to your
pillar data, for example::
    logstash:
        pkg: logstash-altversion
        svc: logstash-alterversion
        pkgstate: installed
        indent: 2
