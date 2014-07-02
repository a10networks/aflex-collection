#################################################
#
# URL Rewrite w/ substitution
#  (c) A10 Networks -- MP
#   v1 20130508
#
#################################################
#
# aFleX script for URL Rewrite with substitution
# of parts of the URI.
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
  set URI [string tolower [HTTP::uri]]  
  regsub -all "/(.*)/pub/health" $URI "/\\1/pub/ping" newuri
  HTTP::uri $newuri
  if { ($::DEBUG == 1) } { log "Rewrite: $URI to $newuri" }
}
