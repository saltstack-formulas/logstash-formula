================
logstash formula
================

Install and configure Logstash for Debian and RedHat based systems using
pillar data.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

    Logstash requires Java, either the Oracle implementation or OpenJDK.  Since
    that is outside the scope of this formula, you must ensure that Java is installed before applying this formula.

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

Example
=======
The easiest way to understand the formula is to look at an example.  The following is example pillar data:

::
    
    logstash:
        inputs:
            -   
                plugin_name: file
                path:
                    - /var/log/syslog
                    - /var/log/authlog
                type: syslog
        filters:
            -
                plugin_name: grok
                match:
                    message: '%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}'
                add_field:
                    received_at: '%{@timestamp}'
                    received_from: '%{host}'
        outputs:
            -
                plugin_name: lumberjack
                hosts:
                    - logs.example.com
                port: 5000
                ssl_certificate: /etc/ssl/certs/lumberjack.crt

That would result in this logstash config (the three separate files it would create are concatenated here):

::

    input {
        file { 
            path => [
                "/var/log/syslog",
                "/var/log/auth.log"
            ]
            type => "syslog"
        }
    }
    filter {
        grok {  
            match => {
                message => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}"
            }
            add_field => {
                received_at => "%{@timestamp}"
                received_from => "%{host}"
            }
        }
        if [log][file][path] and ([log][file][path] == "/var/log/nginx/admin_access.log" {
            mutate {
                add_field => {
                    "[@metadata][target_pipeline]" => "nginx.pipeline"
                    "[@metadata][target_index]" => "access-nginx"
                }
            }
        }
  }
    }
    output {
        lumberjack { 
            hosts => [
                "logs.example.com"
            ]
            port => "5000"
            ssl_certificate => "/etc/ssl/certs/lumberjack.crt"
        }
        if [@metadata][target_pipeline] and [@metadata][target_index] {
            elasticsearch {
                pipeline => "%{[@metadata][target_pipeline]}"
                hosts => "elasticsearch.example.com"
                index => "%{[@metadata][target_index]}-%{+YYYY.MM.dd}"
                ssl => true
                ssl_certificate_verification => true
            }
        }
    }


For a more complicated example, including conditionals, see pillar.example.


Pillar Data Explained
---------------------

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
* The latest version of logstash available will be installed  
  and kept up to date, instead of a one-time install of the latest version
  (e.g. use states.pkg.latest instead of states.pkg.installed)
* The configuration files will use an indentation of four spaces

These settings can be overridden by adding the appropriate keys to your
pillar data, for example::
    logstash:
        pkg: logstash-altversion
        svc: logstash-alterversion
        pkgstate: installed # instead of latest
        indent: 2
