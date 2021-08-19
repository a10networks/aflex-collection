# Title: logging_clients
# Copyright 2015, A10 Networks.
# Version 1.0 - 2015
# Author:   Tony Griffen <training AT a10networks DOT com>
# 
# This aFleX logs Client/Server IP/Port information for security when using Source NAT
# 
# Scalability of this aFleX is unknown.
#
when CLIENT_ACCEPTED {
  set timestamp [TIME::clock seconds]
  set cip [IP::client_addr]
  set cport [TCP::client_port]
  set vip [IP::local_addr]
  set vport [TCP::local_port]
}

when SERVER_CONNECTED {
  set sip [IP::server_addr]
  set sport [TCP::server_port]
  set snat_ip [IP::local_addr]
  set snat_port [TCP::local_port]

  log "\[$timestamp\] $cip:$cport -> $vip:$vport to $snat_ip:$snat_port -> $sip:$sport"
}
