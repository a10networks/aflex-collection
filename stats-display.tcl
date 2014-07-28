#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 1.0 - 20140212
#
# aFleX script to display various statistics
# 1) Requested URIs
# 2) Client IPs
# 3) User-Agents
# 4) Server Response codes
#
# Scalability of this aFleX is unknown.
#

when RULE_INIT {
    set ::DEBUG 0
    set ::TABLES [list "table_uris" "table_clients" "table_user_agents" "table_status_codes"]
}

when HTTP_REQUEST {
    if { [HTTP::uri] equals "/reset:all" } {
        foreach table $::TABLES {
            table delete $table -all
        }
    }
    set response "<html><head><title>Site Statistics</title><meta http-equiv=\"refresh\" content=\"60\"><link rel=\"stylesheet\" href=\"http://a10net.eu/stats/style.css\"></head>"
    append response "<body><center>"
    append response "<p /><table border=\"0\" width=\"75%\" cellpadding=\"2\" cellspacing=\"0\" class=\"maintable\">"
    append response "<tr><td colspan=\"3\" align=\"center\" class=\"credits\">Site Statistics generated with aFleX Site Statistics Collector</a> version 0.1</td></tr>"
    foreach table $::TABLES {
        switch $table {

            "table_uris" {
                append response "<tr><td align=\"center\" class=\"title\" colspan=\"3\">Top 10 Requested pages</td></tr>"
                append response "<tr><td align=\"center\" class=\"subtitle\" colspan=\"3\">Page requests ordered by hits</td></tr>"
            }
            "table_clients" {
                append response "<tr><td align=\"center\" class=\"title\" colspan=\"3\">Top 10 Clients</td></tr>"
                append response "<tr><td align=\"center\" class=\"subtitle\" colspan=\"3\">Clients ordered by hits generated</td></tr>"
            }
            "table_user_agents" {
                append response "<tr><td align=\"center\" class=\"title\" colspan=\"3\">Top 10 User-Agents</td></tr>"
                append response "<tr><td align=\"center\" class=\"subtitle\" colspan=\"3\">User-Agent ordered by major version on occurrence</td></tr>"
            }
            "table_status_codes" {
                append response "<tr><td align=\"center\" class=\"title\" colspan=\"3\">Status Codes</td></tr>"
                append response "<tr><td align=\"center\" class=\"subtitle\" colspan=\"3\">Server response codes</td></tr>"
                set table_status_codes_total 0.0
            }
    }
    set x [list]
    set i 0
    foreach tr [table keys $table] {
        incr i
        if { $i == 1 } {
            set k $tr
        }
        if { $i == 2 } {
            set v $tr
            if { $table eq "table_status_codes" } {
                set table_status_codes_total [expr $table_status_codes_total + $v]
            }
        lappend x [list $k $v]
        set i 0
        }
    }
    set result [lsort -integer -decreasing -index 1 $x]
    set ii 0
    foreach keypair $result {
        incr ii
        if { $ii < 11 } {
            append response "<tr><td class=\"keyentry\">$ii)</td><td class=\"valueentry\">[getfield $keypair " " 2]</td><td class=\"keyentry\">[getfield $keypair " " 1]</td></tr>"
            if { $table eq "table_status_codes" } {
                log "[getfield [expr [getfield $keypair " " 2]/$table_status_codes_total * 100] "." 1]"
                append response "<tr><td class=\"keyentry\">$ii)</td><td class=\"valueentry\">[getfield $keypair " " 1] ([getfield [expr [getfield $keypair " " 2]/$table_status_codes_total * 100] "." 1]%)</td><td class=\"bar\"><img src=\"http://a10net.eu/stats/a10_bar.png\" width=\"[getfield [expr [getfield $keypair " " 2]/$table_status_codes_total * 100] "." 1]\" height=\"8\"></td></tr>"
            }
        }
    }
    append response "<tr><td colspan=\"3\">&nbsp;</td></tr>"
    }
    append response "<tr><td colspan=\"3\" align=\"center\" class=\"info\">This page refreshes every 60 seconds</td></tr>"
    append response "</table></center></body></html>"
    HTTP::respond 200 content $response Content-Type "text/html"
}
