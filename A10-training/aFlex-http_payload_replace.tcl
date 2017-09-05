# Title: http_payload_replace
# Copyright 2015, A10 Networks.
# Version 1.0 - 2015
# Author:   Tony Griffen <training AT a10networks DOT com>
# 
# this aFleX collects the HTTP response and then replaces all instances of
# the pattern "http://" in the payload with "https://"
#  
# Scalability of this aFleX is unknown.
#
when HTTP_REQUEST {
  # remove "Accept-Encoding" header to make sure server doesn't send compressed response
  # (this is done automatically in Rel 2.6.1 and later)
  if { [HTTP::header exists "Accept-Encoding"] } {
    HTTP::header remove "Accept-Encoding"
  }
}

when HTTP_RESPONSE {
  # check Content-Type to avoid unnecessary collects
  if { [HTTP::header "Content-Type"] contains "text" } {
    HTTP::collect
  }
}

when HTTP_RESPONSE_DATA {
  set clen [HTTP::payload length]
  regsub -all "http://" [HTTP::payload] "https://" newdata
  HTTP::payload replace 0 $clen $newdata
  HTTP::release
}
