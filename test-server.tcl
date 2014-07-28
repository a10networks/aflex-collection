#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 1.0 - 20140128
#
# aFleX script that allows you to create easy
# persistence to a specific server in a pool.
#
# To test: http://<VIP>/test:<ip_address_of_server>
# To stop: http://<VIP>/notest
#
# For eample:
#  http://192.168.1.80/test:192.168.1.23
#

when RULE_INIT {
    set ::DEBUG 0
    set ::PORT 80
    set ::TABLE "nodetable"
}

when HTTP_REQUEST {
    if { $::DEBUG == 1 } { log "URI: [HTTP::uri]" }
    if { [HTTP::uri] contains "test" } {
        set ACTION [getfield [HTTP::uri] ":" 1]
        set NODE [getfield [HTTP::uri] ":" 2]
        if { $::DEBUG == 1 } { log "ACTION: $ACTION; NODE: $NODE" }
        switch $ACTION {
            /test {
                table set $::TABLE [IP::client_addr] $NODE indef indef
                if { $::DEBUG == 1 } { log "CREATED ENTRY FOR [IP::client_addr] -> $NODE:$::PORT" }
                HTTP::redirect /
            }
            /notest {
                table delete $::TABLE [IP::client_addr]
                if { $::DEBUG == 1 } { log "ENTRY DELETED FOR [IP::client_addr]" }
                HTTP::redirect /
            }
        }
    }
    set NODE [table lookup $::TABLE [IP::client_addr]]
    if { $NODE != "" } {
        node $NODE $::PORT
        if { $::DEBUG == 1 } { log "ENTRY FOUND: [IP::client_addr] -> $NODE:$::PORT" }
    }
}
