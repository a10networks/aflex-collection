#################################################
#
# URI Based Virtual Hosting
#  (c) A10 Networks -- MP
#   v1 20140128
#
#################################################
#
# aFleX script to be able to do Virtual Hosting
# based on a URI.
# 
# The script will match based on Class-Lists
# For example: http://VIP/cust1
#
# URI to Service-Group mapping
# class-list cl-uri-sg string 
# str /cust1 sg-cust1
# str /cust2 sg-cust2
# str /service sg-service
#
# URI to Host mapping
# class-list cl-uri-fqdn string
# str /cust1 www.cust1.tld
# str /cust2 www.cust2.tld
# str /service service.domain.tld
#
# Questions & comments welcome.
#  mpeters AT a10networks DOT com
#
#################################################

when RULE_INIT {
  set ::DEBUG 0
  set ::SGS “cl-uri-sg"
  set ::FQDNS "cl-uri-fqdn”
}
when HTTP_REQUEST {
  set URI [string tolower [HTTP::uri]]
  set SG [CLASS::match $URI starts_with $::SGS value]
  if { $SG ne ""} {
    set HOST [CLASS::match $URI starts_with $::FQDNS value]
    if { $HOST ne ""} {
      regexp {^/[a-z\-.]+(.*)$} [string tolower [HTTP::uri]] matchall resturi
      HTTP::header replace Host $HOST
      HTTP::uri $resturi
      pool $SG
    }
  if { $::DEBUG == 1 } { log "$URI -> $SG ($HOST) -> $resturi" }
  }
}
