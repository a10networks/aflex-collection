#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 2.0 - 20131211
#
# aFleX script to Secure and HttpOnly JESSIONID
#
# Scalability of this aFleX is unknown.
#

when RULE_INIT {
    set ::DEBUG 0
}

when HTTP_RESPONSE {
    if { [HTTP::cookie exists "JSESSIONID"] } {
        set cookie_val [HTTP::cookie value "JSESSIONID"]
        set cookie_domain [HTTP::cookie domain "JSESSIONID"]
        set cookie_path [HTTP::cookie path "JSESSIONID"]
        if { ($::DEBUG == 1) } { log "JSESSIONID: $cookie_val, $cookie_domain, $cookie_path" }
        if { $cookie_path contains "/login" } {
            set new_cookie_path "/login"
        } elseif { $cookie_path contains "/portal" } {
            set new_cookie_path "/portal"
        } else {
            set new_cookie_path "$cookie_path"
        }
        HTTP::cookie remove "JSESSIONID"
        HTTP::header insert Set-Cookie "JSESSIONID=$cookie_val; Domain=$cookie_domain; Path=$new_cookie_path; Secure; HttpOnly"
    }
}
