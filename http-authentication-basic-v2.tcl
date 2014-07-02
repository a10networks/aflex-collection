#################################################
#
# HTTP(S) Basic Authentication w/ class-lists
#  (c) A10 Networks -- MP
#   v2 20131002
#
#################################################
#
# aFleX script to provide Basic HTTP Authentication
# without the need for an external database.
#
# The class-list for authentication is called
# "cl-passwords" (default) of type "string" and has
# to contain the following data:
# str <username> <sha1 password>
# 
# For example:
# str user1 13646b618f93e6a6f5c4b9fe11c558955e8956d6
# str user2 28517be59120ec2536f5a7a13f95a0d77d547d1f
#
# The optional class-list for the URL list is called
# "cl-url-list" (default) of type "string" and has to 
# contain the following data:
# str <uri>
#
# For example:
# str /sharepoint
# str /portal
#
# When the class-list is not configured every request
# will be authenticated.
#
# Scalability of this aFleX is unknown.
#
# Questions & comments welcome.
#  mpeters AT a10networks DOT com
#
#################################################

when RULE_INIT {
  set ::DEBUG 0
  set ::REALM "Password Required"
  set ::URLLIST "cl-url-list"
  set ::PASSWORDS "cl-passwords"
}

when HTTP_REQUEST {
  set AUTHENTICATE 0
  set URI [string tolower [HTTP::uri]]  
  if { $::DEBUG == 1 } { log "Start AUTHENTICATE: $AUTHENTICATE URI: $URI" }
  if { $::URLLIST eq "" } {
    set AUTHENTICATE 1
    if { $::DEBUG == 1 } { log "Empty URLLIST AUTHENTICATE: $AUTHENTICATE URI: $URI" }
  } elseif { [CLASS::match $URI starts_with $::URLLIST] } {
    set AUTHENTICATE 1
    if { $::DEBUG == 1 } { log "Class-list match AUTHENTICATE: $AUTHENTICATE URI: $URI" }
  }

  if { $AUTHENTICATE == 1 } {
    if { [HTTP::header exists "Authorization"] } {
      set encoded_header [HTTP::header "Authorization"]
      regexp -nocase {Basic (.*)} $encoded_header tmpmatch encoded_string
      set decoded_string [b64decode $encoded_string]
      regexp -nocase {(.*):(.*)} $decoded_string tmpmatch auth_user auth_passwd
      if { [CLASS::match $auth_user equals $::PASSWORDS] } {
        set stored_passwd [CLASS::match $auth_user equals $::PASSWORDS value]
        set auth_passwd_sha1 [sha1 $auth_passwd_clear]
        if { $auth_passwd ne $stored_passwd } {
          HTTP::respond 401 WWW-Authenticate "Basic realm=\"$::REALM\""
        }
      } else {
        HTTP::respond 401 WWW-Authenticate "Basic realm=\"$::REALM\""
      }
    } else {
      HTTP::respond 401 WWW-Authenticate "Basic realm=\"$::REALM\""
    }
  }
}
