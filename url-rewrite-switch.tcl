#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 1.0 - 20111213
#
# aFleX script for URL Rewrite and service-group
# selection.
#
# Scalability of this aFleX is unknown.
#
#

when RULE_INIT {
    set ::DEBUG 0
}

when HTTP_REQUEST {
    set URI [string tolower [HTTP::uri]]
    switch -glob $URI {
        "/shopping*" {
            HTTP::respond 301 Location "http://shopping.example.com"
            if { ($::DEBUG == 1) } { log "Redirected: $URI" }
        }
        "/jobb*" {
            regsub -all "/jobb/?" $URI "/" newuri
            HTTP::uri $newuri
            pool sg-pool
            if { ($::DEBUG == 1) } { log "URI Rewrite for $URI" }
        }
        "/static/0*" {
            regsub -all "/static/0/?" $URI "/" newuri
            HTTP::uri $newuri
            pool sg-pool0
            if { ($::DEBUG == 1) } { log "URI Rewrite for $URI" }
        }
        "/static/1*" {
            regsub -all "/static/1/?" $URI "/" newuri
            HTTP::uri $newuri
            pool sg-pool1
            if { ($::DEBUG == 1) } { log "URI Rewrite for $URI" }
        }
        "/static/2*" {
            regsub -all "/static/2/?" $URI "/" newuri
            HTTP::uri $newuri
            pool sg-pool2
            if { ($::DEBUG == 1) } { log "URI Rewrite for $URI" }
        }
    }
}
