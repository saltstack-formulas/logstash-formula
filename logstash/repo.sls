{%- from 'logstash/map.jinja' import logstash with context %}

{%- if grains['os_family'] == 'Debian' %}
logstash_repo_https_apt_support:
  pkg.installed:
    - name: apt-transport-https

logstash-repo:
  pkgrepo.managed:
    - humanname: Logstash Repo
    - name: deb https://packages.elastic.co/logstash/{{logstash.repoversion}}/debian stable main
    - file: /etc/apt/sources.list.d/beats.list
    - gpgcheck: 1
    - key_url: https://packages.elastic.co/GPG-KEY-elasticsearch
    - require:
      - pkg: apt-transport-https
    - require_in:
      - pkg: logstash

{%- elif grains['os_family'] == 'RedHat' %}
logstash-repo-key:
  cmd.run:
    - name:  rpm --import http://packages.elasticsearch.org/GPG-KEY-elasticsearch
    - unless: rpm -qi gpg-pubkey-d88e42b4-52371eca

logstash-repo:
  pkgrepo.managed:
    - humanname: logstash repository for {{logstash.repoversion}}.x packages
    - baseurl: http://packages.elasticsearch.org/logstash/{{logstash.repoversion}}/centos
    - gpgcheck: 1
    - gpgkey: http://packages.elasticsearch.org/GPG-KEY-elasticsearch
    - enabled: 1
    - require:
      - cmd: logstash-repo-key
{%- endif %}
