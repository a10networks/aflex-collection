# Title: redirect_rewrite
# Copyright 2015, A10 Networks.
# Version 1.0 - 2015
# Author:   Tony Griffen <training AT a10networks DOT com>
# 
# rewrites relative and absolute redirects to absolute HTTPS redirects
# 
# Scalability of this aFleX is unknown.
#

when HTTP_REQUEST {
  set host [HTTP::host]
}

when HTTP_RESPONSE {
  if { [HTTP::is_redirect] } {
    if { [HTTP::header Location] starts_with "/" } {
      HTTP::header replace Location "https://$host[HTTP::header Location]"
    } else {
      HTTP::header replace Location "[string map {"http://" "https://"} [HTTP::header Location]]"
    }
  }
}
