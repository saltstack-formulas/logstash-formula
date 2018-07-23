{% set repo_state = 'absent' %}
{% if salt['pillar.get']('logstash:use_upstream_repo', True) %}
    {% set repo_state = 'managed' %}
{% endif %}
{% set version = salt['pillar.get']('logstash:repo:version', '5') %}
{% set old_repo = salt['pillar.get']('logstash:repo:old_repo', False) %}

{% if old_repo == True %}
{% if grains['os_family'] == 'Debian' %}
logstash-repo-key:
  cmd.run:
    - name: wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
    - unless: apt-key list | grep 'Elasticsearch (Elasticsearch Signing Key)'

logstash-repo:
  pkgrepo.managed:
    - humanname: Logstash Debian Repository
    - name: deb http://packages.elasticsearch.org/logstash/{{ version }}/debian stable main
    - require:
      - cmd: logstash-repo-key
{% elif grains['os_family'] == 'RedHat' %}
logstash-repo-key:
  cmd.run:
    - name:  rpm --import http://packages.elasticsearch.org/GPG-KEY-elasticsearch
    - unless: rpm -qi gpg-pubkey-d88e42b4-52371eca

logstash-repo:
  pkgrepo.managed:
    - humanname: logstash repository for {{ version }}.x packages
    - baseurl: http://packages.elasticsearch.org/logstash/{{ version }}/centos
    - gpgcheck: 1
    - gpgkey: http://packages.elasticsearch.org/GPG-KEY-elasticsearch
    - enabled: 1
    - require:
      - cmd: logstash-repo-key
{% endif %}

{% elif old_repo == False %}
{% if grains['os_family'] == 'Debian' %}
logstash-repo:
    pkg.installed:
        - name: apt-transport-https

    pkgrepo.{{ repo_state }}:
        - name: deb https://artifacts.elastic.co/packages/{{ version }}.x/apt stable main
        - file: /etc/apt/sources.list.d/elastic.list
        - gpgcheck: 1
        - key_url: https://artifacts.elastic.co/GPG-KEY-elasticsearch
        - require:
            - pkg: apt-transport-https

{% elif salt['grains.get']('os_family') == 'RedHat' %}
logstash-repo:
    pkgrepo.{{ repo_state }}:
        - name: elastic
        - humanname: "Elastic repository for " ~ {{ version }} ~ ".x packages"
        - baseurl: https://artifacts.elastic.co/packages/{{ version }}.x/yum
        - gpgkey: https://artifacts.elastic.co/GPG-KEY-elasticsearch
        - gpgcheck: 1
        - disabled: False

{% endif %}
{% endif %}
