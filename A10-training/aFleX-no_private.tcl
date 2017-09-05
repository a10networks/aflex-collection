#
# Copyright 2017, A10 Networks.
# Version 1
#
# Blocks access of specific IP to specific URI
#
# Scalability of this aFleX is unknown.
#
when HTTP_REQUEST {
    if { [IP::addr [IP::client_addr] equals 172.16.1.1] and [HTTP::uri] starts_with "/private" } {
        reject
        log local0.INFO "Stopped [IP::client_addr] from accessing /private directory"
    }
}

