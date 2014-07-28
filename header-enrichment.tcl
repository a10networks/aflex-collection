#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 1.0 - 20130924
#
# aFleX script to provide Header Enrichment for
# the purpose of policy based Traffic Steering.
#
# This comes in 2 parts.
# 1) Script that is bound to a RADIUS VPORT.
# 2) Script that is bound to a HTTP VPORT.
#
# Scalability of this aFleX is unknown.
#

#
# Virtual Server Port: RADIUS
#
when RULE_INIT {
    set ::DEBUG 0
}

when CLIENT_DATA {
    binary scan [RADIUS::avp 40] H* avp40
    if { ($::DEBUG == 1) } { log "RADIUS == User-Name=[RADIUS::avp 1], User-Password=[RADIUS::avp 2], Framed-IP-Address=[RADIUS::avp 8], Filter-Id=[RADIUS::avp 11], Calling-Station-Id=[RADIUS::avp 31], Acct-Status-Type=$avp40" }
    if { $avp40 == 1 } {
        table set msisdn [RADIUS::avp 8] [RADIUS::avp 31] indef
        table set policy [RADIUS::avp 8] [RADIUS::avp 11] indef
        if { ($::DEBUG == 1) } { log "RADIUS == TABLE SET MSISDN: [table lookup msisdn [RADIUS::avp 8]] - POLICY: [table lookup policy [RADIUS::avp 8]]" }
    } elseif { $avp40 == 2 } {
        table delete msisdn [RADIUS::avp 8]
        table delete policy [RADIUS::avp 8]
        if { ($::DEBUG == 1) } { log "RADIUS == TABLE DELETE MSISDN: [table lookup msisdn [RADIUS::avp 8]] - POLICY: [table lookup policy [RADIUS::avp 8]]" }
    }
}


#
# Virtual Server Port: HTTP
#
when RULE_INIT {
    set ::DEBUG 0
}

when HTTP_REQUEST {
    HTTP::header insert MSISDN [table lookup msisdn [IP::client_addr]]
    HTTP::header insert User-Type [table lookup policy [IP::client_addr]]
    if { ($::DEBUG == 1) } { log "HTTP == MSISDN: [table lookup msisdn [IP::client_addr]] - POLICY: [table lookup policy [IP::client_addr]]" }
}
