#
# Copyright 2014, Carl Caira <ccaira AT a10networks DOT com>, A10 Networks.
# Version 1.0 - 20140611
#
# aFleX script to present a Sorry Page with images in local cache.
#
# 1) Upload the image to the cache using the following command;
# "import local-uri-file <local-file-name> [use-mgmt-port] [username <name>] <path>"
# For example:
# import local-uri-file logo.jpg use-mgmt-port ftp://ftp@192.168.1.23/images/logo.jpg
#
# 2) Create a RAM Cache template that references the image (as local-uri)
# For example:
# slb template cache tp-cache
#    policy local-uri /logo.jpg
#
# 3) Apply the RAM template AND aflex to the vPort;
# For example:
# slb virtual-server vip1 192.168.4.251
#   port 80  http
#      template cache tp-cache
#      aflex sorry-page
#
# Scalability of this aFleX is unknown.
#

when RULE_INIT {
    set ::PAGE_CONTENT "<html><head><title>Page Not Found</title></head>
        <body><h2><center>Page Not found</center></h2>It appears as though the page
        you're looking for has not been found on the server.  Please use the Back
        button of your browser, or try a link from our <a href=\"http://www.example.com\">
        Main Page</a> <p> <center><img src=\"logo.jpg\" width=\"180\" height=\"69\"
        alt=\"Logo\" /> <\center></body></html>"
}

when LB_FAILED {
    log "Server LB Selection Failed - Sorry Page used"
    HTTP::respond 503 content $::PAGE_CONTENT
}
