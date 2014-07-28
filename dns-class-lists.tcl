#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 1.0 - 20120716
#
# aFleX script to block specific DNS names.
#
# The class-list for domains is called
# "cl-dns-list" (default) of type "string" and has
# to contain the following data:
# str <.domain.tld>
#
# For example:
# str .madrid.org
# str .madrid.com
#
# Scalability of this aFleX is unknown.
#

when RULE_INIT {
    set ::DEBUG 0
    set ::CLASSLIST "cl-dns-list"
}

when DNS_REQUEST {
    if { !([DNS::question name] equals ".") } {
        set fqdn .[DNS::question name]
        if { $::DEBUG == 1 } { log "fqdn: $fqdn" }
    }
    if { [CLASS::match $fqdn ends_with $::CLASSLIST] } {
        if { $::DEBUG == 1 } { log "Dropped: [DNS::question name] from [IP::client_addr]" }
        drop
    }
}
