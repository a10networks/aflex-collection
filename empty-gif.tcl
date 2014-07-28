#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 1.0 - 20120928
#
# aFleX script to generate an empty gif.
#
# Scalability of this aFleX is unknown.
#

when HTTP_REQUEST {
    HTTP::respond 200 content "<html><img src=\"data:image/gif;base64,R0lGODlhAQABAPABAP///wAAACH5BAEKAAAALAAAAAABAAEAAAICRAEAOw%3D%3D\" width=1 height=1></html>"
}
