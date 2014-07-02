#################################################
#
# URL Rewrite w/ switch
#  (c) A10 Networks -- MP
#   v1 20111213
#
#################################################
#
# aFleX script for URL Rewrite and service-group
# selection.
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
  set URI [string tolower $URI]
  switch -glob $URI {
    "/shopping*" {
      HTTP::respond 301 Location "http://shopping.domain.tld"
      if { ($::DEBUG == 1) } { log "Redirected: $URI" }
    }
    "/jobb*" {
      regsub -all "/jobb/?" $URI "/" newuri
      HTTP::uri $newuri
      pool jobb_varnish
      if { ($::DEBUG == 1) } { log "URI Rewrite for $URI" }
    }
    "/static/0*" {
      regsub -all "/static/0/?" $URI "/" newuri
      HTTP::uri $newuri
      pool varnish_0
      if { ($::DEBUG == 1) } { log "URI Rewrite for $URI" }
    }
    "/static/1*" {
      regsub -all "/static/1/?" $URI "/" newuri
      HTTP::uri $newuri
      pool varnish_1
      if { ($::DEBUG == 1) } { log "URI Rewrite for $URI" }
    }
    "/static/2*" {
      regsub -all "/static/2/?" $URI "/" newuri
      HTTP::uri $newuri
      pool varnish_2
      if { ($::DEBUG == 1) } { log "URI Rewrite for $URI" }
    }
  }
}
