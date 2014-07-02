#################################################
#
# Rate-limit for Failed Requests per timeframe
#  (c) A10 Networks -- MP
#   v1 20140312
#
#################################################
#
# aFleX script to rate-limit based on requests
# per second and failed responses from the server.
#
# ::MAX_FAILED holds the number of requests that can be
# done before the client is blacklisted.
#
# The ::HOLDTIME_FAILED is the time in seconds.
#
# ::RATE is the amount of requests per timeframe (in seconds)
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
  set ::DEBUG 0
  set ::MAX_FAILED 10
  set ::HOLDTIME_FAILED 20
  set ::RATE 2
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
}

when HTTP_RESPONSE {
  if { ([HTTP::status] == 404) or ([HTTP::status] == 500) or ([HTTP::status] == 503) } {
    if { [table lookup tmp_failed $IP] == "" } {
      table set tmp_failed $IP $::RATE
      if { $::DEBUG > 2 } { log "$IP -> failed response counter created" }
    }
  
    set failed_count [table incr tmp_failed $IP]
    if { $::DEBUG > 2 } { log "$IP -> $failed_count of $::MAX_FAILED failed requests" }
    table lifetime tmp_failed $IP $::RATE
  
    if { $failed_count > $::MAX_FAILED } {
      table add blacklist $IP "failed response" indef $::HOLDTIME_FAILED
      if { $::DEBUG >= 1 } { log "$IP -> blacklisted for $::HOLDTIME_FAILED seconds" }
      table delete tmp_failed $IP
      if { $::DEBUG > 2 } { log "$IP -> removed from tmp_failed" }
      return
    }
  }
}
