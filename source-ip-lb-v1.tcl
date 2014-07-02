#################################################
#
# Source IP Load Balancing Decision w/ class-lists
#  (c) A10 Networks -- MP
#   v1 20131003
#
#################################################
#
# aFleX script to provide Source IP load balancing
# decision for a service-group.
# (Currently this is not supported with bw-list in ADP)
#
# The class-list for the IP list is called
# "cl-adfs-ips" (default) and has
# to contain the following data:
# <ip> /<netmask> 
# 
# For example:
# 10.110.102.0 /24
# 172.30.0.0 /22
#
# Scalability of this aFleX is unknown.
#
# Questions & comments welcome.
#  mpeters AT a10networks DOT com
#
#################################################

when RULE_INIT {
  set ::DEBUG 0
  set ::CLASSLIST "cl-adfs-ips"
}

when CLIENT_ACCEPTED {
  if { [CLASS::match [IP::client_addr] $::CLASSLIST ip] } {
    if { $::DEBUG == 1 } { log "CLASS::match on [IP::client_addr]" }
    pool sg-adfs
  } else {
    if { $::DEBUG == 1 } { log "IP [IP::client_addr] not found on class-list" }
    pool sg-adfs-proxy
  }
}
