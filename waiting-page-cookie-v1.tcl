#################################################
#
# Waiting page for busy site w/ Cookies
#  (c) A10 Networks -- MP
#   v1 20121025
#
#################################################
#
# aFleX script to present clients a waiting page
# when the site has X amount of active users.
# Persistency table is build with the Cookies.
#
# Scalability of this aFleX is unknown.
#
# Questions & comments welcome.
#  mpeters AT a10networks DOT com
#
#################################################

when RULE_INIT {
  set ::DEBUG 0
  set ::MAXUSERS 50
}

when HTTP_REQUEST {
  set THRESHOLD "no"
  set cookievalue [HTTP::cookie value WPTOKEN]
  if { $cookievalue ne "" } {
    set persist_entry [persist lookup uie $cookievalue]
  }
  set active_users [persist size uie global]
  if { ($::DEBUG == 1) } { log "Currently [persist size uie global] active users" }

  if { $active_users > $::MAXUSERS } {
    set THRESHOLD "yes"
    if { $persist_entry eq "" } {
      HTTP::respond 503 content "<html><head><title>Temporarily Unreachable</title><style type=\"text/css\"> body { font-family: arial; color: black; background: white; } a { color: black; }</style></head><body><center><p>This site is temporarily unreachable. There are currently $active_users active users. Please try again in 10 minutes.<br /><br /></p></center></body></html>"
    } elseif { $persist_entry ne "" } {
      persist uie { $cookievalue } 600
    }
  }
}

when HTTP_RESPONSE {
  if { $THRESHOLD eq "no" } {
    if { $persist_entry eq "" } {
      log "if persist"
      set char_set {0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K a b c d e f g}
      set len 28
      set cookieval {}
      for { set i 0 } { $i < 10 } { incr i } {
        set index [expr { int(rand()*$len) }]
        append cookieval [lindex $char_set $index]
      }
      HTTP::cookie insert name WPTOKEN value $cookieval
      persist add uie { $cookieval } 600
      if { ($::DEBUG == 1) } { log "New persist entry created: $cookieval" }
    }
  }
}
