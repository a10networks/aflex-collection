# Title: redirect1
# Copyright 2015, A10 Networks.
# Version 1.0 - 2015
# Author:   Tony Griffen <training AT a10networks DOT com>
# 
# redirect HTTP request to https URL
# 
# Scalability of this aFleX is unknown.
#

when HTTP_REQUEST {
  HTTP::redirect https://[HTTP::host][HTTP::uri]
}
