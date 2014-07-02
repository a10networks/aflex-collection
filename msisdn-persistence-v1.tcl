#################################################
#
# MSISDN Based Persistency
#  (c) A10 Networks -- MP
#   v1 20131022
#
#################################################
#
# aFleX script to provide persistence based on
# the users MSISDN 
# 
# This comes in 2 parts.
# 1) Script that is bound to a RADIUS VPORT.
# 2) Script that is bound to a HTTP VPORT.
#
# For the HTTP VPORT script some global variables
# have to be set:
# 1) ::SERVICEGROUP, to point to the service-group
# that will be used.
# 2) ::MEMBERS, the actual real servers that are in the
# service-group. Starting at 0.
#
# When no MSISDN will be found the hash will always
# match the first real server in the service-group.
#
# Scalability of this aFleX is unknown.
#
# Questions & comments welcome.
#  mpeters AT a10networks DOT com
#
#################################################
#
# VPORT: RADIUS
#
when RULE_INIT {
  set ::DEBUG 0
}

when CLIENT_DATA {
  binary scan [RADIUS::avp 40] H* avp40
 
  if { ($::DEBUG == 1) } { log "User-Name=[RADIUS::avp 1], User-Password=[RADIUS::avp 2], Framed-IP-Address=[RADIUS::avp 8], Filter-Id=[RADIUS::avp 11], Calling-Station-Id=[RADIUS::avp 31], Acct-Status-Type=$avp40" }

  if { $avp40 == 1 } {
    table set msisdn [RADIUS::avp 8] [RADIUS::avp 31] indef

    if { ($::DEBUG == 1) } { log "TABLE SET MSISDN: [table lookup msisdn [RADIUS::avp 8]]" }

  } elseif { $avp40 == 2 } {
    table delete msisdn [RADIUS::avp 8]

    if { ($::DEBUG == 1) } { log "TABLE DELETE MSISDN: [table lookup msisdn [RADIUS::avp 8]]" }
  }
}


#
# VPORT: HTTP
#
when RULE_INIT {
  set ::DEBUG 0
  set ::SERVICEGROUP "<service-group>"
  array set ::MEMBERS {
   "0" "192.168.1.1"
   "1" "192.168.1.2"
   "2" "192.168.1.3"
   "3" "192.168.1.4"
  }
}

when HTTP_REQUEST {
  set MSISDN [table lookup msisdn [IP::client_addr]]
  set hashbin ""
  set port [TCP::local_port]
  binary scan [md5 $MSISDN] i1 hashbin
  set n [expr $hashbin % [members $::SERVICEGROUP]]
  set REAL $::MEMBERS($n)
  set m [expr $n + 1]
  set BACKUPREAL $::MEMBERS($m)

  if { ($::DEBUG == 1) } { log "MSISDN: [table lookup msisdn [IP::client_addr]]" }
  if { ($::DEBUG == 1) } { log "Hash: $hashbin -- n: $n" }
  if { ($::DEBUG == 1) } { log "Local Port: [TCP::local_port]" }
  if { ($::DEBUG == 1) } { log "Member Count: [members $::SERVICEGROUP] -- Member List: [members list $::SERVICEGROUP]" }

  if { [LB::status node $REAL port [TCP::local_port] tcp] equals "up"} {
    pool $::SERVICEGROUP member $REAL [TCP::local_port]
    if { ($::DEBUG == 1) } { log "Server $REAL port [TCP::local_port] is UP and was selected" }
  } else {
    pool $::SERVICEGROUP member $BACKUPREAL $port
    log "Server $REAL port [TCP::local_port] is DOWN -- $BACKUPREAL was selected"
  }
}