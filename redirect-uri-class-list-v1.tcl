#################################################
#
# Redirect URI w/ class-list
#  (c) A10 Networks -- MP
#   v1 20120716
#
#################################################
#
# aFleX script to do URI redirection with a class-list.
#
# The class-list for the redirects is called
# "cl-redirects" (default) of type "string" and has
# to contain the following data:
# str <uri> <url>
# 
# For example:
# str /userpage1 http://clients1.domain.tld/users/user1
# str /userpage2 https://www.domain.tld/client2
#
# Scalability of this aFleX is unknown.
#
# Questions & comments welcome.
#  mpeters AT a10networks DOT com
#
#################################################

when RULE_INIT {
  set ::DEBUG 0
  set ::CLASSLIST "cl-redirects"
}

when HTTP_REQUEST {
  set URI [string tolower [HTTP::uri]]  
  set redirect_url [CLASS::match $URI equals $::CLASSLIST value]
  if { $redirect_url != ""} {
    HTTP::redirect $redirect_url
    if { $::DEBUG == 1 } { log "Redirected: $URI -> $redirect_url" }
  }
}
