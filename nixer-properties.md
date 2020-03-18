---
layout: page
homepage: true
short_title: "Nixer Properties"
side_menu: true
permalink: /nixer-properties/
---

# Nixer Application Properties Reference

{% for module in site.data.nixer-props-metadata %}
{% assign name = module[0] %}
{% assign data = module[1] %}
    
## {{ name | capitalize }} properties
    
{:.table}
| Key          | Default Value | Description |
|--------------|---------------|-------------|{% for prop in  data.spring-configuration-metadata.properties %}
| `{{ prop.name }}` | {% if prop.defaultValue != %}`{{ prop.defaultValue }}`{% endif %} | {{ prop.description }} |{% endfor %}   
    

{% endfor %}
