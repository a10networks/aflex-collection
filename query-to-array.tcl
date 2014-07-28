#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 1.0 - 20140321
#
# aFleX script to convert the HTTP query string
# to individual elements in an array.
#
# To use an individual variable pair do:
#   $query(<variable_name>)
# For example:
#   $query(edition)
#
# ::DEBUG can be set to 1, 2 or 3.
#
# Scalability of this aFleX is unknown.
#
#

when RULE_INIT {
    set ::DEBUG 0
}

when HTTP_REQUEST {
    if { [HTTP::query] != "" } {
        set http_query [HTTP::query]
        if { $::DEBUG > 2 } { log "Complete query: $http_query" }
        set tmp_query [split $http_query "&"]
        if { $::DEBUG > 2 } { log "Split query: $tmp_query" }
        foreach kv $tmp_query {
            array set query [split $kv "="]
            if { $::DEBUG > 2 } { log "Each pair: $kv" }
        }
        if { $::DEBUG > 1 } { log "Array size: [array size query]" }
        if { $::DEBUG >= 1 } { log "Variable names: [array names query]" }
    }
}
