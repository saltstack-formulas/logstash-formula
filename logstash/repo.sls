{%- if grains['os_family'] == 'Debian' %}
logstash-repo:
  pkgrepo.managed:
    - humanname: Logstash Debian Repository for 2.1.x packages
    - name: deb http://packages.elastic.co/logstash/2.1/debian stable main
    - gpgcheck: 1
    - key_url: https://packages.elastic.co/GPG-KEY-elasticsearch
{%- elif grains['os_family'] == 'RedHat' %}
logstash-repo:
  pkgrepo.managed:
    - humanname: logstash repository for 2.1.x packages
    - baseurl: http://packages.elastic.co/logstash/2.1/centos
    - gpgcheck: 1
    - gpgkey: http://packages.elastic.co/GPG-KEY-elasticsearch
    - enabled: 1
{%- endif %}
