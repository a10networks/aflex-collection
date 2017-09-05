#
# Title: udp_echo
# Copyright 2017, A10 Networks.
# Version 0.3 - 20170901
# Author:   Eric Nute <training AT a10networks DOT com>#
#
# aFleX script to provide simple UDP echo server for testing purposes
# Example virtual-server:
#   slb virtual-server udp-echo 10.10.10.10
#      port 4343  udp
#         aflex udp-echo
#
# Scalability of this aFleX is unknown.
#
when CLIENT_DATA {
    set RESP [UDP::payload 512]
	
	# set PAD "IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII\r\n"
	# set RESP "$RESP $PAD $PAD $PAD $PAD"
	
	UDP::respond $RESP
	
}
