#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 1.0 - 20131008
#
# aFleX script to select an SSL Template based
# on the Local IP.
#
# The class-list for the redirects is called
# "cl-ssl-templates" (default) of type "string" and has
# to contain the following data:
# str <ip> <template>
#
# For example:
# str 172.16.100.57 client-ssl1
# str 172.16.100.58 client-ssl2
#
# Scalability of this aFleX is unknown.
#

when RULE_INIT {
    set ::DEBUG 0
    set ::CLASSLIST "cl-ssl-templates"
    set ::DEFAULTSSL "client-ssl1"
    set ::POOL "http-sg"
}

when CLIENT_ACCEPTED {
    set LocalIP [IP::local_addr]
    set SSLTemplate [CLASS::match $LocalIP equals $::CLASSLIST value]
    if { $SSLTemplate != ""} {
        SSL::template clientside $SSLTemplate
        pool $::POOL
        if { $::DEBUG == 1 } { log "SSL Template: $LocalIP -> $SSLTemplate" }
    } else {
        SSL::template clientside $::DEFAULTSSL
        pool $::POOL
    }
}
