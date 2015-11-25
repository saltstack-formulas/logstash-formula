{%- from 'logstash/map.jinja' import logstash with context %}

{% if logstash.version.startswith('2') and salt['grains.get']('os_family', None) == "Debian" %}
{% set versionstring="1:" + logstash.version %}
{% else %}
{% set versionstring = logstash.version %}
{% endif %}

include:
  - .repo
  - .plugin

logstash-pkg:
  pkg.{{ logstash.pkgstate }}:
    - name: {{logstash.pkg}}
    - version: "{{ versionstring }}"
    - require:
      - pkgrepo: logstash-repo

# This gets around a user permissions bug with the logstash user/group
# being able to read /var/log/syslog, even if the group is properly set for
# the account. The group needs to be defined as 'adm' in the init script,
# so we'll do a pattern replace.

{%- if salt['grains.get']('os', None) == "Ubuntu" %}
change service group in Ubuntu init script:
  file.replace:
    - name: /etc/init.d/logstash
    - pattern: "LS_GROUP=logstash"
    - repl: "LS_GROUP=adm"
    - watch_in:
      - service: logstash-svc

add adm group to logstash service account:
  user.present:
    - name: logstash
    - groups:
      - logstash
      - adm
    - require:
      - pkg: logstash-pkg
{%- endif %}

{%- if logstash.inputs is defined %}
logstash-config-inputs:
  file.managed:
    - name: /etc/logstash/conf.d/01-inputs.conf
    - user: root
    - group: root
    - mode: 755
    - source: salt://logstash/files/01-inputs.conf
    - template: jinja
    - require:
      - pkg: logstash-pkg
{%- else %}
logstash-config-inputs:
  file.absent:
    - name: /etc/logstash/conf.d/01-inputs.conf
{%- endif %}

{%- if logstash.filters is defined %}
logstash-config-filters:
  file.managed:
    - name: /etc/logstash/conf.d/02-filters.conf
    - user: root
    - group: root
    - mode: 755
    - source: salt://logstash/files/02-filters.conf
    - template: jinja
    - require:
      - pkg: logstash-pkg
{%- else %}
logstash-config-filters:
  file.absent:
    - name: /etc/logstash/conf.d/02-filters.conf
{%- endif %}

{%- if logstash.outputs is defined %}
logstash-config-outputs:
  file.managed:
    - name: /etc/logstash/conf.d/03-outputs.conf
    - user: root
    - group: root
    - mode: 755
    - source: salt://logstash/files/03-outputs.conf
    - template: jinja
    - require:
      - pkg: logstash-pkg
{%- else %}
logstash-config-outputs:
  file.absent:
    - name: /etc/logstash/conf.d/03-outputs.conf
{%- endif %}

{% if logstash.env is defined %}
logstash-env:
  file.managed:
    - name: /etc/default/logstash
    - mode: 664
    - user: root
    - group: root
    - source: salt://logstash/files/default
    - template: jinja
    - require:
      - pkg: logstash-pkg
    - defaults:
      config: {{ logstash.env | json }}
{% endif %}

logstash-svc:
  service.running:
    - name: {{logstash.svc}}
    - enable: true
    - require:
      - pkg: logstash-pkg
    - watch:
      - file: logstash-config-inputs
      - file: logstash-config-filters
      - file: logstash-config-outputs
{% if logstash.env is defined %}
      - file: logstash-env
{% endif %}
