cookbook-keepalived-director
============================

<H1>Introduction</H1>
This Chef cookbook can be used to configure [Keepalived](http://www.keepalived.org/) for virtual directors. 
Before running this cookbook, the cookbook [cookbook-keepalived-realserver](https://github.com/sbbird/cookbook-keepalived-realserver) should be executed. 

<H1>Usage</H1>
1. Configure other directees by [cookbook-keepalived-realserver](https://github.com/sbbird/cookbook-keepalived-realserver). 
2. Add this cookbook into run list. It will search for node with tag ```lvs-real-server``` and generate ```/etc/keepalived/keepalived.conf```.
