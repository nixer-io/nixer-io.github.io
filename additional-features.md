---
layout: page
homepage: true
short_title: Additional Features
side_menu: true
order: 23
permalink: /additional-features/
---

# Additional Features

Features internally utilized by Nixer Spring Plugin which also can be used individually.

### File-based Bloom Filter

We provide file-based Bloom filter implementation which can efficiently handle large, i.e. multi-GB, data sets.
The implementation is available as a Java library, additionally we prepared a command-line tool for manipulating the filters.

For more information see the [detailed Bloom filter documentation]({{ site.baseurl }}/bloom-filter).

### Cloud IP Ranges Supplier

Most big cloud providers publish their IP addresses ranges. Information whether an IP address belongs to a particular cloud provider
might be valuable for various reasons, e.g. as a hint for a suspicious request in our context.  

We provide a simple script extracting the current IP addresses lists from various cloud providers. 
You can find more information [on the documentation page]({{ site.baseurl }}/cloud-ip-ranges).

<!--# Other Resources-->