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

<table class="table table-striped table-bordered table-hover" style="table-layout: fixed; word-wrap: break-word;">
<colgroup>
<col style="width: 40%;">
<col style="width: 15%;">
<col style="width: 45%;">
</colgroup>
<thead>
<tr class="header">
<th >Key</th>
<th >Default Value</th>
<th >Description</th>
</tr>
</thead>
<tbody>

{% for prop in  data.spring-configuration-metadata.properties %}
{% if prop.name contains "nixer" %}
<tr>
<td markdown="span">`{{ prop.name }}`</td>
<td markdown="span">{% if prop.defaultValue %}`{{ prop.defaultValue }}`{% endif %}</td>
<td markdown="span">{{ prop.description }}</td>
</tr>
{% endif %}
{% endfor %}   

</tbody>
</table>
    

{% endfor %}
