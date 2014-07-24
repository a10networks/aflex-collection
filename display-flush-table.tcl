#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 1.0 - 20131213
#
# aFleX script to display and flush contents
# of the requested table.
#
# To display: http://<VIP>/status:<table_name>
# To flush: http://<VIP>/flush:<table_name>
#
# For eample:
#  http://192.168.1.80/display:usertable
#

when HTTP_REQUEST {
 set ACTION [getfield [HTTP::uri] ":" 1]
 set TABLE [getfield [HTTP::uri] ":" 2]

 if { $ACTION eq "/flush" } {
   table delete $TABLE -all
   HTTP::respond 200 content "Table $TABLE deleted... <a href=\"/status:$TABLE\">Back to STATUS</a>" Content-Type "text/html"
 } elseif { $ACTION eq "/status" } {
   set response "<html><head><title>Contents of Table: $TABLE</title></head>"
   append response "<body><center><h1>Contents of Table: $TABLE</h1><table border=\"1\" cellpadding=\"5\" cellspacing=\"0\">"
   append response "<tr><th>Key</th><th>Value</th></tr>"
   set i 0
   foreach tr [table keys $TABLE] {
     incr i
     if { $i == 1 } {
       append response "<tr><td>$tr</td>"
     }
     if { $i == 2 } {
       append response "<td>$tr</td></tr>"
       set i 0
     }
   }
   append response "</table><p>DELETE TABLE: <a href=\"/flush:$TABLE\">$TABLE</a></p>"
   append response "</center></body></html>"
   HTTP::respond 200 content $response Content-Type "text/html"
 } else {
   HTTP::respond 200 content "Usage is prohibited!"
 }
}
