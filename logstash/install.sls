{%- from 'logstash/map.jinja' import logstash with context %}

logstash-pkg:
  pkg.{{logstash.pkgstate}}:
    - name: {{logstash.pkg}}
