#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 1.0 - 20140212
#
# aFleX script to collect various statistics
# 1) Requested URIs
# 2) Client IPs
# 3) User-Agents
# 4) Server Response codes
#
# Scalability of this aFleX is unknown.
#

when RULE_INIT {
    set ::DEBUG 0
    set ::EXCLUDE_EXTENSION [list "css" "js" "ico" "png" "jpg" "bmp" "gif"]
}

when HTTP_REQUEST {
    set TMP_URI [getfield [HTTP::uri] "." 2]
    set URI [getfield $TMP_URI "?" 1]
    if { [lsearch -glob $::EXCLUDE_EXTENSION $URI] == -1 } {
        if { [table lookup table_uris [HTTP::uri]] == "" } {
            table add table_uris [HTTP::uri] 1 indef indef
        } elseif { [HTTP::uri] != "" } {
            table incr table_uris [HTTP::uri]
        }
    }
    if { [HTTP::header exists User-Agent] } {
        set user_agent [getfield [HTTP::header User-Agent] " " 1]
        if { [table lookup table_user_agents $user_agent] == "" } {
            table add table_user_agents $user_agent 1 indef indef
        } else {
            table incr table_user_agents $user_agent
        }
    }
    if { [table lookup table_clients [IP::client_addr]] == "" } {
        table add table_clients [IP::client_addr] 1 indef indef
    } elseif { [IP::client_addr] != "" } {
        table incr table_clients [IP::client_addr]
    }
}

when HTTP_RESPONSE {
    if { [table lookup table_status_codes [HTTP::status]] == "" } {
        table add table_status_codes [HTTP::status] 1 indef indef
    } elseif { [HTTP::status] != "" } {
        table incr table_status_codes [HTTP::status]
    }
}
