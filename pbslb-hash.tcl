#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 1.0 - 20131209
#
# aFleX script to combine PBSLB IP matching with
# IP hashing as a fallback.
#
# Format PBSLB:
# 10.0.0.0/16 1
# 192.168.1.0/24 2
#
# For the IP HASH it's required to have separate
# Service-Groups. So the hashing can map to these
# names.
#
# NOTE: LID 0 in the PBSLB list can _not_ be used.
#

when RULE_INIT {
    set ::DEBUG 0
    set ::PBSLB "pbslb"
    set ::MAXSG 32
}

when CLIENT_ACCEPTED {
    set IP [IP::client_addr]
    if { $::DEBUG == 1 } { log "ClientIP: $IP" }
    set LID [POLICY::bwlist id $IP $::PBSLB]
    if { $LID > 0 } {
        pool sg-test$LID
        if { $::DEBUG == 1 } { log "PBSLB Match - Service-Group: sg-test$LID" }
    } else {
        binary scan [md5 $IP] I1 hashbin
        if { $::DEBUG == 1 } { log "SCAN: $hashbin" }
        set HASH [expr $hashbin % $::MAXSG]
        pool sg-hash$HASH
        if { $::DEBUG == 1 } { log "No PBSLB Match - Service-Group: sg-hash$HASH" }
    }
}
