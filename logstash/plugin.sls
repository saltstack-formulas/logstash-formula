{%- from 'logstash/map.jinja' import logstash with context %}

{% if logstash.plugin_install %}
{% if logstash.version.startswith('2') %}
{% for plugin in logstash.plugin_install %}
logstash_plugin_{{ plugin.name }}:
  cmd.run:
    - name: /opt/logstash/bin/plugin install --version {{ plugin.version }} {{ plugin.name }}
    - creates: /opt/logstash/vendor/bundle/jruby/1.9/gems/{{ plugin.name }}-{{ plugin.version }}
    - require:
      - pkg: logstash
{% endfor %}
{% endif %}
{% endif %}

extend:
  logstash:
    service:
      - watch:
{% for plugin in logstash.plugin_install %}
        - cmd: logstash_plugin_{{ plugin.name }}
{% endfor %}
