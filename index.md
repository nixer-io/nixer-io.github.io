---
layout: page
homepage: true
---

# Docs Home

This is home of the documentation for [Nixer Spring Plugin](https://github.com/nixer-io/nixer-spring-plugin). 

The documentation is organised into following sections:

* [Overview]({{ site.baseurl }}#overview) describes at high level the idea of the plugin, the problem it attempts to solve
and motivation behind the chosen solution.

* [How?]({{ site.baseurl }}#how) explains in what way the plugin is meant to solve the problem.

* [Getting Started]({{ site.baseurl }}#getting-started) guides you through the steps involved in applying Nixer Spring Plugin 
to your application. 

* [Modules]({{ site.baseurl }}#modules) outlines how the plugin is organised into libraries, 
each representing different protection mechanism.

* [Examples]({{ site.baseurl }}#examples) of complete applications using the plugin.

* [Additional Features]({{ site.baseurl }}#additional-features) offered by Nixer open source software, apart of the plugin.

* [Other Resources]({{ site.baseurl }}#other-resources) like articles, videos, etc. 

# Overview

The plugin for [Spring framework](https://github.com/spring-projects/spring-framework) 
provides protection against credential stuffing attacks to your Spring-based web application.

## Credential Stuffing

Credential Stuffing is a peculiar attack on web applications. Technically it is a very basic and easy to understand attack 
closely related to brute force techniques, yet it is frighteningly effective. 
 
To learn more about credential stuffing take a look at [OWASP definition](https://www.owasp.org/index.php/Credential_stuffing) or our 
[introductory article into the subject](https://medium.com/@jbron/credential-stuffing-how-its-done-and-what-to-do-with-it-57ad66302ce2).

## Why Spring plugin?

The motivation for releasing this open source plugin is to give more insight and control to the developers of web applications. 
Majority of available protection software runs as an external piece complicating the architecture and introducing yet another point 
of failure into the system. In addition, the task of detecting credential stuffing often requires statistical learning or machine learning 
which results in a black-box software that can't explain its decisions. Also such third-party servers require access 
to the HTTP traffic, which creates data privacy and security concerns. Administrators are usually reluctant to adopt that kind of black-box 
protections. It is not easy to enforce adoption of such solutions within the organization. 
   
Apart from privacy and infrastructure considerations, there are also data science related advantages of such approach. 
External software needs to read a lot of things directly from HTTP traffic. The process of feature engineering and data augmentation 
is harder and usually results in complicated algorithms. By moving heuristics directly into the application, we are no longer forced to 
decode HTTP traffic and we have access to much broader application context. This is especially powerful in Spring, where a lot of 
configuration parameters about the application are available internally. By leveraging Spring's well-thought architecture it is possible to 
create a library that provides control and ease of integration.

# How?
## Detection
Detection mechanisms

## Protection
Protection mechanisms

## Rules
Rules description

# Getting Started

# Modules
This section outlines how the plugin is organised into modules, each representing different protection mechanism.

* [Core]({{ site.baseurl }}/core) - core functionality of Nixer Spring Plugin.

* [Captcha]({{ site.baseurl }}/captcha) - dynamic captcha challenge.

* [Pwned Check]({{ site.baseurl }}/pwned-check) - suspicious credentials check.

* [Stigma]({{ site.baseurl }}/stigma) - device stamping mechanism.

# Extending Nixer
How to create your own extensions to the plugin.

# Examples

For full usage examples please see the following:

* [Internal example, most up-to-date, local dependency resolution](https://github.com/nixer-io/nixer-spring-plugin/tree/master/samples/example)

* [External example, aligned to the latest release, real dependency resolution](https://github.com/nixer-io/nixer-spring-plugin-integrations/tree/master-with-nixer-plugin/nixer-spring-plugin-demo-app)


# Additional Features
Bloom filter

# Other Resources
