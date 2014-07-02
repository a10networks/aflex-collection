#################################################
#
# Calling-Station-Id Based Persistency
#  (c) A10 Networks -- MP
#   v1 20131212
#
#################################################
#
# aFleX script to provide persistence based on
# the users Calling-Stattion-Id 
#
# Specific use case is Wireless Lan Controller
# Radius Authentication load balancing
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

when CLIENT_DATA {
  if { ($::DEBUG == 1) } { log "User-Name=[RADIUS::avp 1], Calling-Station-Id=[RADIUS::avp 31]" }
  persist uie [RADIUS::avp 31]
}
