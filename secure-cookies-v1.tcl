#################################################
#
# Secure and HttpOnly Cookies
#  (c) A10 Networks -- MP
#   v1 20131211
#
#################################################
#
# aFleX script to Secure and HttpOnly Cookies
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
      set cookie_value [HTTP::cookie value "$cookie_name"]
      set cookie_expires [HTTP::cookie expires "$cookie_name"]
      set cookie_domain [HTTP::cookie domain "$cookie_name"]
      set cookie_path [HTTP::cookie path "$cookie_name"]
      set new_cookie "$cookie_name=$cookie_value"
      if { $cookie_expires > $current_time } {
        set new_expire [clock format $cookie_expires -format {%a, %d %b %Y %H:%M:%S GMT} -gmt 1]
        append new_cookie "; Expires=$new_expire" }
      if { $cookie_domain ne "" } { append new_cookie "; Domain=$cookie_domain" }
      if { $cookie_path ne "" } { append new_cookie "; Path=$cookie_path" }
      if { $PORT == 443 } { append new_cookie "; Secure" }
      if { $PORT == 80 or $PORT == 443 } { append new_cookie "; HttpOnly" }
      if { ($::DEBUG == 1) } { log "Set-Cookie $new_cookie" }
      HTTP::cookie remove "$cookie_name"
      HTTP::header insert Set-Cookie "$new_cookie"
    }
  }
}