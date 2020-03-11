---
layout: page
homepage: true
short_title: Overview
side_menu: true
permalink: /overview/
---

# Overview

The plugin for [Spring framework](https://github.com/spring-projects/spring-framework) 
provides protection against credential stuffing attacks to your Spring-based web application.

### Credential Stuffing

Credential Stuffing is a peculiar attack on web applications. Technically it is a very basic and easy to understand attack 
closely related to brute force techniques, yet it is frighteningly effective. 
 
To learn more about credential stuffing take a look at [OWASP definition](https://www.owasp.org/index.php/Credential_stuffing) or our 
[introductory article into the subject](https://medium.com/@jbron/credential-stuffing-how-its-done-and-what-to-do-with-it-57ad66302ce2).

### Why Spring Plugin?

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
