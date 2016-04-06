{%- from 'logstash/map.jinja' import logstash with context %}

# This is more like a meta-state that installs, configures and starts Logstash.
# You can use this if you don't really want to change anything about the states.
# It's also a lot cleaner to just have - logstash in your top.sls

include:
  - .repo
  - .install
  - .config
  - .service
