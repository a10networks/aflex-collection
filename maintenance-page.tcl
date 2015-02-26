#
# Always display a maintenance page when this aFlex is active
# Use the class list "maintenanceip" to exclude IP (ranges) from
# displaying the mainenance page
#
# For example:
# class-list maintenanceip ipv4
# 127.0.0.1 /32
# !
#
# Rijnier <rijnier@intermax.nl>
#

when RULE_INIT {
  set ::DEBUG 0
  set ::MaintenanceIP "maintenanceip"
}

when HTTP_REQUEST {
  if { [CLASS::match [IP::client_addr] $::MaintenanceIP ip] != 1 } {
    HTTP::respond 200 content "HTML stuff goes here"
  }
}
