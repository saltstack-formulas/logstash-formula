{%- from 'logstash/map.jinja' import logstash with context %}

include:
  - .repo

logstash-pkg:
  pkg.{{logstash.pkgstate}}:
    - name: {{logstash.pkg}}
    - require:
      - pkgrepo: logstash-repo

logstash-svc:
  service:
    - name: {{logstash.svc}}
    - running
    - enable: true
    - require:
      - pkg: logstash-pkg

logstash-config-inputs:
  file.managed:
    - name: /etc/logstash/conf.d/01-inputs.conf
    - user: root
    - group: root
    - mode: 775
    - source: salt://logstash/files/01-inputs.conf
    - template: jinja
    - watch_in:
      - service: logstash-svc
    - require:
      - pkg: logstash-pkg

logstash-config-filters:
  file.managed:
    - name: /etc/logstash/conf.d/02-filters.conf
    - user: root
    - group: root
    - mode: 755
    - source: salt://logstash/files/02-filters.conf
    - template: jinja
    - watch_in:
      - service: logstash-svc
    - require:
      - pkg: logstash-pkg

logstash-config-outputs:
  file.managed:
    - name: /etc/logstash/conf.d/03-outputs.conf
    - user: root
    - group: root
    - mode: 755
    - source: salt://logstash/files/03-outputs.conf
    - template: jinja
    - watch_in:
      - service: logstash-svc
    - require:
      - pkg: logstash-pkg