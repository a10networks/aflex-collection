#
# Title: http_dummy_server
# Copyright 2015, A10 Networks.
# Version 1.1 - 20170901
# Author:   Tony Griffen <training AT a10networks DOT com>
# Author:   Eric Nute <training AT a10networks DOT com>
#
# aFleX script to provide simple HTTP server for testing purposes
# Responds to client HTTP requests with a web page
# consisting of client's request headers
#
# Example virtual-server:
#   slb virtual-server dummy_server 10.10.10.10
#      port 80  http
#         aflex http_dummy_server
#
# Scalability of this aFleX is unknown.
#

when HTTP_REQUEST {
    set RESP "<h1>Your request:</h1>
    <font color=\"#003333\"><b>Server IP:Port</b></font>: [IP::local_addr]:[TCP::local_port]<br>
    <font color=\"#003333\"><b>Client IP:Port</b></font>: [IP::client_addr]:[TCP::client_port]<br>
    <font color=\"#003333\"><b>Requested URI</b></font>: [HTTP::uri]<br>
    <font color=\"#003333\"><b>Method</b></font>: [HTTP::method]<br>"
    foreach head [HTTP::header names] {
        set RESP "$RESP <font color=\"#003333\"><b>$head</b></font>: [HTTP::header values $head]<br>"
    }
#	set PAD "IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII <br>IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII <br>IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII <br>IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII <br>IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII"
#    set RESP "$RESP $PAD"
    set STYLE "<head>
    <style>
    body {
        background-color: white;
        font-family: Consolas;
        font-size: 12pt;
    }
    h1 {
        color: maroon;
        font-family: Cambria;
        font-size: 20pt;
    }
    </style>
    </head>"

    HTTP::respond 200 content "<html>$STYLE<body>$RESP</body></html>"
}

