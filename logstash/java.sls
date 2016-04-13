{%- from 'logstash/map.jinja' import logstash with context %}

logstash-java-pkg-requirement:
  pkg.installed:
    - name: {{logstash.javapkg}}
