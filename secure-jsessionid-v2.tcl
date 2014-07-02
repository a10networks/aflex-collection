#################################################
#
# Secure and HttpOnly for JESSIONID Cookie
#  (c) A10 Networks -- MP
#   v1 20130707
#   v2 20131211 - Fixed typo
#
#################################################
#
# aFleX script to Secure and HttpOnly JESSIONID
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
