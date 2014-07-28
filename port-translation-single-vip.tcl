#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 1.0 - 20131003
#
# aFleX script to provide API port translation.
#
# Requires real servers en ports to be configured
# and to be member of a service-group.
# On the VIP it needs a VPORT 0 TCP
#
# Scalability of this aFleX is unknown.
#

when RULE_INIT {
    set ::DEBUG 0
    set ::REALPORT 8080
}

when CLIENT_ACCEPTED {
    set destport [TCP::local_port]
    if { $destport < 2001 or $destport > 2020 } {
        if { ($::DEBUG == 1) } { log "Drop connection for port $destport" }
        drop
    }
    switch $destport {
        "2001" { set target 192.168.1.1 }
        "2002" { set target 192.168.1.2 }
        "2003" { set target 192.168.1.3 }
        "2004" { set target 192.168.1.4 }
        "2005" { set target 192.168.1.5 }
        "2006" { set target 192.168.1.6 }
        "2007" { set target 192.168.1.7 }
        "2008" { set target 192.168.1.8 }
        "2009" { set target 192.168.1.9 }
        "2010" { set target 192.168.1.10 }
        "2011" { set target 192.168.1.11 }
        "2012" { set target 192.168.1.12 }
        "2013" { set target 192.168.1.13 }
        "2014" { set target 192.168.1.14 }
        "2015" { set target 192.168.1.15 }
        "2016" { set target 192.168.1.16 }
        "2017" { set target 192.168.1.17 }
        "2018" { set target 192.168.1.18 }
        "2019" { set target 192.168.1.19 }
        "2020" { set target 192.168.1.20 }
    }
    if { ($::DEBUG == 1) } { log "Target $target on port $::REALPORT" }
    node $target $::REALPORT
}
