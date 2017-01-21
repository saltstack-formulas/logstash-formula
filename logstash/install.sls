{%- from 'logstash/map.jinja' import logstash with context %}

{%- if not logstash.use_upstream_repo %}
{#- NOP #}
{%- elif grains['os_family'] == 'Debian' %}
logstash_repo:
  pkgrepo.managed:
    - name: {{ logstash.upstream_repo }}
    - file: /etc/apt/sources.list.d/elastic-{{ logstash.upstream_repo_version }}.list
    - gpgcheck: 1
    - keyid: D88E42B4
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - pkg: logstash-pkg
    - watch_in:
      - pkg: logstash-pkg

{%- elif grains['os_family'] == 'RedHat' %}
logstash_repo:
  pkgrepo.managed:
    - name: elk_logstash
    - humanname: Elasticsearch repository for 2.x packages
    - baseurl: https://packages.elastic.co/beats/yum/el/x86_64
    - gpgcheck: 1
    - gpgkey: https://packages.elastic.co/GPG-KEY-elasticsearch
    - require_in:
      - pkg: logstash-pkg
    - watch_in:
      - pkg: logstash-pkg
{%- endif %}

# Make sure that the JRE package is installed first.  The Ubuntu/Debian
# logstash packages does not list the JRE as a prerequisite, causing the
# installation to fail.
jre_pkg:
  pkg.{{ logstash.pkgstate }}:
    - pkgs:
      - {{ logstash.jre_pkg }}
    {%- if logstash.pkgstate == 'installed' %}
    - skip_suggestions: True
    {%- endif %}

logstash-pkg:
  pkg.{{ logstash.pkgstate }}:
    - pkgs:
      - {{ logstash.pkg }}
    {%- if logstash.pkgstate == 'installed' %}
    - skip_suggestions: True
    {%- endif %}
    - require:
      - pkg: jre_pkg
