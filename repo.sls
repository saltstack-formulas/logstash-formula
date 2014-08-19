{%- if grains['os_family'] == 'Debian' %}
logstash-repo-key:
  cmd.run:
    - name: wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
    - unless: apt-key list | grep 'Elasticsearch (Elasticsearch Signing Key)'

logstash-repo:
  pkgrepo.managed:
    - humanname: Logstash Debian Repository
    - name: deb http://packages.elasticsearch.org/logstash/1.4/debian stable main
    - require:
      - cmd: logstash-repo-key
{%- elif grains['os_family'] == 'RedHat' %}
logstash-repo-key:
  cmd.run:
    - name:  rpm --import http://packages.elasticsearch.org/GPG-KEY-elasticsearch
    - unless: rpm -qi gpg-pubkey-d88e42b4-52371eca

logstash-repo:
  pkgrepo.managed:
    - humanname: logstash repository for 1.4.x packages
    - baseurl: http://packages.elasticsearch.org/logstash/1.4/centos
    - gpgcheck: 1
    - gpgkey: http://packages.elasticsearch.org/GPG-KEY-elasticsearch
    - enabled: 1
    - require:
      - cmd: logstash-repo-key
{%- endif %}