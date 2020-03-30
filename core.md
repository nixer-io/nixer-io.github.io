---
layout: page
homepage: true
short_title: "Module: Core"
side_menu: true
permalink: /core/
---

# Core

Provides base functionality of Nixer Spring Plugin. 
It supplies the communication mechanism with the Spring application being integrated into, 
serves as ground for the other [Nixer modules]({{ site.baseurl }}/modules) and any custom extensions, rules or behaviors. 

Apart of the above the Core module also brings basic detection and protection features, like:

- monitoring the ratio of login failures over time
- monitoring login attempts anomalies correlated with IP addresses, usernames or User-Agents
- detecting IP addresses coming from suspicious providers
- and applying specific, configurable, behaviors to the system basing on all the measurements above.

### Installation

Core Nixer plugin is distributed through [Maven Central]({{ site.project.mvn_repo_url }}).

It requires dependency to Core Nixer plugin as well.

```kotlin
dependencies {
    implementation("io.nixer:nixer-plugin-core:{{ site.project.version }}")
}
```

### Usage

Usage of the plugin can bee seen in the [Getting Started]({{ site.baseurl }}/getting-started) guide.
