#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 1.0 - 20120716
#
# aFleX script to do HOST redirection with a class-list.
#
# The class-list for the redirects is called
# "cl-redirects" (default) of type "string" and has
# to contain the following data:
# str <host> <full url>
#
# For example:
# str client1.domain.tld https://clients1.domain.tld/users/user1
# str www.domain.tld https://www.domain.tld/
#
# Scalability of this aFleX is unknown.
#

when RULE_INIT {
    set ::DEBUG 0
    set ::CLASSLIST "cl-redirects"
}

when HTTP_REQUEST {
    set HOST [string tolower [HTTP::host]]
    set redirect_url [CLASS::match $HOST equals $::CLASSLIST value]
    if { $redirect_url != ""} {
        HTTP::redirect $redirect_url
        if { $::DEBUG == 1 } { log "Redirected: $HOST -> $redirect_url" }
    }
}
