# Title: host_switching
# Copyright 2015, A10 Networks.
# Version 1.0 - 2015
# Author:   Tony Griffen <training AT a10networks DOT com>
# 
# This aFleX example illustrates the use of Tcl associative arrays to implement
# host switchin
# 
# Scalability of this aFleX is unknown.
#
when RULE_INIT {
  array set ::SG_ARRAY [list "youtube.com" "sg1" "google.com" "sg2" "zynga.com" "sg2"]
}

when HTTP_REQUEST {
  set host [HTTP::host]
  if { [info exists ::SG_ARRAY($host)] } {
    log "host $host -> pool $::SG_ARRAY($host)"
    pool $::SG_ARRAY($host)
  }
}
