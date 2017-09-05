# Title: redirect2
# Copyright 2015, A10 Networks.
# Version 1.0 - 2015
# Author:   Tony Griffen <training AT a10networks DOT com>
# 
# This example uses HTTP::respond to do a redirect with a cookie set
# 
# Scalability of this aFleX is unknown.
#

when HTTP_REQUEST {
  set cookie "val=100; path=/; domain=mydomain.com"
  HTTP::respond 302 Location "http://mydomain.com" "Set-Cookie" $cookie
}
