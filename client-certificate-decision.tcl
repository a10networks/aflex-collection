#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 1.0 - 20131005
#
# aFleX script to make decisions based on the CA
# and Common Name of a Client Certificate.
#
# Scalability of this aFleX is unknown.
#

when RULE_INIT {
  set ::DEBUG 0
}

when CLIENTSSL_CLIENTCERT {
  set CCcert [SSL::cert 0]
  set CCsubject [X509::subject $CCcert]
  if { $::DEBUG == 1 } { log "Client SSL Cert Subject: $CCsubject -- Complete Cert: $CCcert" }
}

when HTTP_REQUEST {
  if { [HTTP::uri] matches {/api/[0-9]*} } {
    if { $CCsubject matches {*<CA_SIGNER>*} } {
      do something...
      if { $CCsubject matches {*<CN>*} } {
        do something...
      }
    } else {
     if { $::DEBUG == 1 } { log "SSL Connection is dropped" }
      drop
    }
  }
}
