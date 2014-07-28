#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 1.0 - 20120730
#
# aFleX script for host based cache selection for TCS.
#
# Contents of the array ::CACHEURLS needs to be in
# the form:
# "<url>" "<service_group>"
#
# For example:
# "youtube.com" "cache_group2"
#
# Scalability of this aFleX is unknown.
#

when RULE_INIT {
    set ::DEBUG 0
    array set ::CACHEURLS {
        "youtube.com" "cache_group1"
        "googlevideo.com" "cache_group1"
        "facebook.com" "cache_group1"
        "apple.com" "cache_group2"
        "fbcdn.net" "cache_group1"
        "googlesyndication.com" "cache_group1"
        "gstatic.com" "cache_group2"
        "gmodules.com" "cache_group2"
        "googleapis.com" "cache_group2"
        "doubleclick.net" "cache_group3"
        "ebay.com" "cache_group3"
        "last.fm" "cache_group3"
        "microsoft.com" "cache_group3"
        "msn.com" "cache_group3"
        "soundcloud.com" "cache_group3"
        "twitter.com" "cache_group3"
        "yahoo.com"  "cache_group3"
        "zynga.com" "cache_group3"
    }
}

when HTTP_REQUEST {
    set HOST [string tolower [HTTP::host]]
    set URI [string tolower [HTTP::uri]]
    set l1 [string last . $HOST]
    set l2 [string last . $HOST [incr l1 -1]]
    set HOST [string range $HOST [incr l2] 200]
    if { $::DEBUG == 1 } { log "HOST: $HOST" }
    if { [info exists ::CACHEURLS($HOST)] } {
        set SERVICEGROUP $::CACHEURLS($HOST)
        if { $::DEBUG == 1 } { log "service-group: $SERVICEGROUP" }
        pool $SERVICEGROUP
    } else {
        if { $::DEBUG == 1 } { log "Not whitelisted -> pool gateway" }
        pool gateway
    }
}
