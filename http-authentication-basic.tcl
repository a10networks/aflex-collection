#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 2.0 - 20131002
#
# aFleX script to provide Basic HTTP Authentication
# without the need for an external database.
#
# The class-list for authentication is called
# "cl-passwords" (default) of type "string" and has
# to contain the following data:
# str <username> <sha1 password>
#
# For example:
# str user1 13646b618f93e6a6f5c4b9fe11c558955e8956d6
# str user2 28517be59120ec2536f5a7a13f95a0d77d547d1f
#
# The optional class-list for the URL list is called
# "cl-url-list" (default) of type "string" and has to
# contain the following data:
# str <uri>
#
# For example:
# str /sharepoint
# str /portal
#
# When the class-list is not configured every request
# will be authenticated.
#
# Scalability of this aFleX is unknown.
#

when RULE_INIT {
    set ::DEBUG 0
    set ::REALM "Password Required"
    set ::URLLIST "cl-url-list"
    set ::PASSWORDS "cl-passwords"
}

when HTTP_REQUEST {
    set AUTHENTICATE 0
    set URI [string tolower [HTTP::uri]]
    if { $::DEBUG == 1 } { log "Start AUTHENTICATE: $AUTHENTICATE URI: $URI" }
    if { $::URLLIST eq "" } {
        set AUTHENTICATE 1
        if { $::DEBUG == 1 } { log "Empty URLLIST AUTHENTICATE: $AUTHENTICATE URI: $URI" }
    } elseif { [CLASS::match $URI starts_with $::URLLIST] } {
        set AUTHENTICATE 1
        if { $::DEBUG == 1 } { log "Class-list match AUTHENTICATE: $AUTHENTICATE URI: $URI" }
    }
    if { $AUTHENTICATE == 1 } {
        set ACCESS 0
        if { [HTTP::header exists "Authorization"] } {
            set encoded_string [findstr [HTTP::header value "Authorization"] "Basic " 6]
            set basic_values [split [b64decode $encoded_string] ":"]
            set auth_user [lindex $basic_values 0]
            binary scan [sha1 [lindex $basic_values 1]] H* auth_passwd
            if { [CLASS::match $auth_user equals $::PASSWORDS] } {
                if { [CLASS::match $auth_user equals $::PASSWORDS value] eq $auth_passwd } {
                    set ACCESS 1
                    HTTP::header remove "Authorization"
                }
            }
        }
        if { $ACCESS == 0 } {
            HTTP::respond 401 WWW-Authenticate "Basic realm=\"$::REALM\""
        }
    }
}
