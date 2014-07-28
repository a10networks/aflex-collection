#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 1.0 - 20130508
#
# aFleX script for URL Rewrite with substitution
# of parts of the URI.
#
# Scalability of this aFleX is unknown.
#

when RULE_INIT {
    set ::DEBUG 0
}

when HTTP_REQUEST {
    set URI [string tolower [HTTP::uri]]
    regsub -all "/(.*)/pub/health" $URI "/\\1/pub/ping" newuri
    HTTP::uri $newuri
    if { ($::DEBUG == 1) } { log "Rewrite: $URI to $newuri" }
}
