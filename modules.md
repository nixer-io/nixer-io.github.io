---
layout: page
homepage: true
short_title: "Modules"
side_menu: true
permalink: /modules/
---

# Modules

The plugin is divided into modules that offer distinct features. 
Depending on what features you need, you may choose selectively what modules to integrate into your application.

Nixer modules are available in [Maven Central]({{ site.project.mvn_repo_url }}).

Currently we provide the following modules:

- [Core]({{ site.baseurl }}/core)
- [Captcha]({{ site.baseurl }}/captcha)
- [Pwned Check]({{ site.baseurl }}/pwned-check)
- [Stigma]({{ site.baseurl }}/stigma)

Nixer plugin leverages Spring Boot 
[auto-configuration mechanism](https://docs.spring.io/spring-boot/docs/current/reference/html/using-spring-boot.html#using-boot-auto-configuration).
Each module comes with it's own auto-configuration limiting this way efforts required to configure the application.  
