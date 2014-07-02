#################################################
#
# Secure and HttpOnly Cookies (minimal)
#  (c) A10 Networks -- MP
#   v1 20131212
#
#################################################
#
# aFleX script to Secure and HttpOnly Cookies
# with minimal variables
#
# Checks on incoming port to either apply Secure
# and / or HttpOnly.
#
# Scalability of this aFleX is unknown.
#
# Questions & comments welcome.
#  mpeters AT a10networks DOT com
#
#################################################
 
when RULE_INIT {
  set ::DEBUG 0
}
 
when HTTP_REQUEST {
  set PORT [TCP::local_port]
}
 
when HTTP_RESPONSE {
  set current_time [TIME::clock seconds]
  foreach cookie_name [HTTP::cookie names] {
    if { [HTTP::cookie exists "$cookie_name"] } {
      set new_cookie "$cookie_name=[HTTP::cookie value "$cookie_name"]"
      if { [HTTP::cookie expires "$cookie_name"] > $current_time } {
        set cookie_expires [clock format [HTTP::cookie expires "$cookie_name"] -format {%a, %d %b %Y %H:%M:%S GMT} -gmt 1]
        append new_cookie "; Expires=$cookie_expires" }
      if { [HTTP::cookie domain "$cookie_name"] ne "" } { append new_cookie "; Domain=[HTTP::cookie domain "$cookie_name"]" }
      if { [HTTP::cookie path "$cookie_name"] ne "" } { append new_cookie "; Path=[HTTP::cookie path "$cookie_name"]" }
      if { $PORT == 443 } { append new_cookie "; Secure" }
      if { $PORT == 80 or $PORT == 443 } { append new_cookie "; HttpOnly" }
      if { ($::DEBUG == 1) } { log "Set-Cookie $new_cookie" }
      HTTP::cookie remove "$cookie_name"
      HTTP::header insert Set-Cookie "$new_cookie"
    }
  }
}