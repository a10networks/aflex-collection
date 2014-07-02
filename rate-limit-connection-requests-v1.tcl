#################################################
#
# Rate-limit for Connections and Requests
#  (c) A10 Networks -- MP
#   v1 20140205
#
#################################################
#
# aFleX script to rate-limit based on connections
# and requests per second.
#
# ::MAX_ holds the number of requests that can be
# done before the client is blacklisted.
#
# The ::HOLDTIME_ is the time in seconds.
#
# ::DEBUG can be set to 1, 2 or 3.
#
# Scalability of this aFleX is unknown.
#
# Questions & comments welcome.
#  mpeters AT a10networks DOT com
#
#################################################

when RULE_INIT {
  set ::DEBUG 1
  set ::MAX_CONNECTIONS 20
  set ::MAX_REQUESTS 15
  set ::HOLDTIME 60
}

when CLIENT_ACCEPTED {
  set IP [IP::remote_addr]
  if { [table lookup blacklist $IP] != "" } {
    reject
    if { $::DEBUG > 1 } { log "$IP -> blacklist expires in [table lifetime blacklist -remaining $IP] seconds" }
    return
  }
  if { [table lookup tmp_blacklist $IP] == "" } {
    table set tmp_blacklist $IP 1
    if { $::DEBUG > 2 } { log "$IP -> connection counter created" }
  }

  set count [table incr tmp_blacklist $IP]
  if { $::DEBUG > 2 } { log "$IP -> $count of $::MAX_CONNECTIONS connection" }
  table lifetime tmp_blacklist $IP 2

  if { $count > $::MAX_CONNECTIONS } {
    table add blacklist $IP "Connection Reached" indef $::HOLDTIME
    if { $::DEBUG >= 1 } { log "$IP -> blacklisted for $::HOLDTIME seconds" }
    table delete tmp_blacklist $IP
    if { $::DEBUG > 2 } { log "$IP -> removed from tmp_blacklist" }
    reject
    return
  }
}

when HTTP_REQUEST {
  set IP [IP::client_addr]
  if { [table lookup tmp_request $IP] == "" } {
    table set tmp_request $IP 1
    if { $::DEBUG > 2 } { log "$IP -> request counter created" }
  }

  set request_count [table incr tmp_request $IP]
  if { $::DEBUG > 2 } { log "$IP -> $request_count of $::MAX_REQUESTS requests" }
  table lifetime tmp_request $IP 2

  if { $request_count > $::MAX_REQUESTS } {
    table add blacklist $IP "Requests Reached" indef $::HOLDTIME
    if { $::DEBUG >= 1 } { log "$IP -> blacklisted for $::HOLDTIME seconds" }
    table delete tmp_request $IP
    if { $::DEBUG > 2 } { log "$IP -> removed from tmp_request" }
    HTTP::respond 200 content "429 Too Many Requests. Your access will be resumed in 60 seconds."
    return
  }
}
