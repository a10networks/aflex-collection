#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 1.0 - 20121025
#
# aFleX script to present clients a waiting page
# when the site has X amount of active users.
# Persistency table is build with the Client IP.
#
# Scalability of this aFleX is unknown.
#

when RULE_INIT {
    set ::DEBUG 0
    set ::MAXUSERS 50
}

when HTTP_REQUEST {
    set THRESHOLD "no"
    set client_ip [IP::client_addr]
    set persist_entry [persist lookup uie $client_ip]
    set active_users [persist size uie global]
    if { ($::DEBUG == 1) } { log "Currently [persist size uie global] active users" }
    if { $active_users > $::MAXUSERS } {
        set THRESHOLD "yes"
        if { $persist_entry eq "" } {
            HTTP::respond 503 content "<html><head><title>Temporarily Unreachable</title><style type=\"text/css\"> body { font-family: arial; color: black; background: white; } a { color: black; }</style></head><body><center><p>This site is temporarily unreachable. There are currently $active_users active users. Please try again in 10 minutes.<br /><br /></p></center></body></html>"
        } elseif { $persist_entry ne "" } {
            persist uie { $client_ip } 600
        }
    }
}

when HTTP_RESPONSE {
    if { $THRESHOLD eq "no" } {
        persist add uie { $client_ip } 600
        if { ($::DEBUG == 1) } { log "New persist entry created: $client_ip" }
    }
}
