#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 1.0 - 20131004
#
# aFleX script to drop certain DNS queries.
#
# Scalability of this aFleX is unknown.
#

when RULE_INIT {
  set ::DEBUG 0
}

when DNS_REQUEST {
  if { $::DEBUG == 1 } { log "Question: name: [DNS::question name] - type: [DNS::question type] - Query ID: [DNS::header id] - RD: [DNS::header rd]" }
  if { [DNS::question type] eq "ANY" } {
    if { $::DEBUG == 1 } { log "Drop ANY query from [IP::client_addr]" }
    drop
  } elseif { [DNS::header rd] } {
    drop
    if { $::DEBUG == 1 } { log "Drop RD query from [IP::client_addr]" }
  } elseif { [DNS::header id] == "<number>" } {
    drop
    if { $::DEBUG == 1 } { log "Drop Query ID '<number>' from [IP::client_addr]" }
  }
}
