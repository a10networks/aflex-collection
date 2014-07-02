#################################################
#
# Rate-limit for Requests and Failed Requests
#  (c) A10 Networks -- MP
#   v1 20140205
#
#################################################
#
# aFleX script to rate-limit based on requests
# per second and failed responses from the server.
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
  set ::MAX_REQUESTS 10
  set ::MAX_FAILED 5
  set ::HOLDTIME_REQUESTS 30
  set ::HOLDTIME_FAILED 600
}

when HTTP_REQUEST {
  set IP [IP::client_addr]
  if { [table lookup blacklist $IP] != "" } {
    reject
    if { $::DEBUG > 1 } { log "$IP -> blacklist expires in [table lifetime blacklist -remaining $IP] seconds" }
    return
  }
  if { [table lookup tmp_blacklist $IP] == "" } {
    table set tmp_blacklist $IP 1
    if { $::DEBUG > 2 } { log "$IP -> request counter created" }
  }

  set count [table incr tmp_blacklist $IP]
  if { $::DEBUG > 2 } { log "$IP -> $count of $::MAX_REQUESTS requests" }
  table lifetime tmp_blacklist $IP 2

  if { $count > $::MAX_REQUESTS } {
    table add blacklist $IP "over limit" indef $::HOLDTIME_REQUESTS
    if { $::DEBUG >= 1 } { log "$IP -> blacklisted for $::HOLDTIME_REQUESTS seconds" }
    table delete tmp_blacklist $IP
    if { $::DEBUG > 2 } { log "$IP -> removed from tmp_blacklist" }
    reject
    return
  }
}

when HTTP_RESPONSE {
  if { ([HTTP::status] == 404) or ([HTTP::status] == 500) or ([HTTP::status] == 503) } {
    if { [table lookup tmp_failed $IP] == "" } {
      table set tmp_failed $IP 1
      if { $::DEBUG > 2 } { log "$IP -> failed response counter created" }
    }
  
    set failed_count [table incr tmp_failed $IP]
    if { $::DEBUG > 2 } { log "$IP -> $failed_count of $::MAX_FAILED failed requests" }
    table lifetime tmp_failed $IP 2
  
    if { $failed_count > $::MAX_FAILED } {
      table add blacklist $IP "failed response" indef $::HOLDTIME_FAILED
      if { $::DEBUG >= 1 } { log "$IP -> blacklisted for $::HOLDTIME_FAILED seconds" }
      table delete tmp_failed $IP
      if { $::DEBUG > 2 } { log "$IP -> removed from tmp_failed" }
      return
    }
  }
}
