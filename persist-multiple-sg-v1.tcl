#################################################
#
# Persist over different service-groups
#  (c) A10 Networks -- MP
#   v1 20140104
#
#################################################
#
# aFleX script to provide persistence when two
# different service-groups are used
#
# Questions & comments welcome.
#  mpeters AT a10networks DOT com
#
#################################################

when RULE_INIT {
  set ::DEBUG 0
  set ::SERVICEGROUP "PROD_WEBAPPS"
  set ::MAXMEMBERS 2
  array set ::MEMBERS {
   "1" "172.21.82.51"
   "2" "172.21.82.52"
  }
}

when HTTP_REQUEST {
  set PORT [TCP::local_port]
  set NUMBER [table lookup hashtable [IP::client_addr]]
  if { $NUMBER != "" } {
    set REAL $::MEMBERS($NUMBER)
    if { $::DEBUG == 1 } { log "TABLE Hit - MEMBER: $NUMBER - $REAL -> $PORT" }
  } else {
    set IP [IP::client_addr]
    if { $::DEBUG == 1 } { log "ClientIP: $IP" }
    set HASH [expr { int(1 + rand() * $::MAXMEMBERS) }]
    table set hashtable $IP $HASH 3600
    set REAL $::MEMBERS($HASH)
    if { $::DEBUG == 1 } { log "No Table Match - Service-Group: $REAL }
  }
  pool $::SERVICEGROUP:$PORT member $REAL [TCP::local_port]
}
