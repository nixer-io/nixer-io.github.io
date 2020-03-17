---
layout: page
homepage: true
short_title: Concepts
side_menu: true
permalink: /concepts/
---

# Concepts

### Rules
To obtain high-configurability and control, we decided to introduce concept of rules. We are not using any rule-based system with inference algorithms, the idea is not to have a huge rule system. For now it's a concept for structuring processing logic and control.

We use rules to determine what actions to perform based on the request and it's metadata. These rules can prioritize certain actions, combine them etc.

We also use rules to for defining protection mechanisms. Various rules can be created, for example: 
   *  If user failed to login in last 5 tries, display a captcha
   *  if percentage of successful login attempts is lower than 60% display captcha for login attempts
   *  If user uses leaked password and his IP comes from suspicious provider, log the incident
   *  If user-agent string has a login success rate <40%, display captcha to all requests with that user-agent string

