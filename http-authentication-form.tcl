#
# Copyright 2014, Mischa Peters <mpeters AT a10networks DOT com>, A10 Networks.
# Version 2.0 - 20131002
#
# aFleX script to provide HTTP Authentication
# without the need for an external database.
#
# The class-list for authentication needs to
# be called "passwords" of type "string" and has
# to contain the following data:
# str <username> <sha1 password>
#
# For example:
# str user1 13646b618f93e6a6f5c4b9fe11c558955e8956d6
# str user2 28517be59120ec2536f5a7a13f95a0d77d547d1f
#
# Scalability of this aFleX is unknown.
#

when RULE_INIT {
    set ::DEBUG 0
    set ::AUTHENTICATED "no"
    set ::FORM_CONTENT "<html><header><title>Authentication</title></header><body><center><h2>Please Authenticate</h2><table border=\"0\"><form method=\"POST\"><tr><td>Username:</td><td><input type=\"text\" name=\"form_username\" /></td></tr><tr><td>Password:</td><td><input type=\"password\" name=\"form_password\" /></td></tr><tr><td colspan=\"2\">&nbsp;</td></tr><tr><td align=\"center\" colspan=\"2\"><input type=\"submit\" /></td></tr></form></table></center></body></html>"
}

when HTTP_REQUEST {
    set client_ip [IP::client_addr]
    set persist_entry [persist lookup uie $client_ip]
    if { [HTTP::method] eq "POST" and $persist_entry eq "" } {
        HTTP::collect
    } elseif { [HTTP::method] ne "POST" and $persist_entry eq "" } {
        HTTP::respond 200 content $::FORM_CONTENT
    }
}

when HTTP_REQUEST_DATA {
    if { [HTTP::method] eq "POST" } {
        if { ($::DEBUG == 1) } { log "PAYLOAD: [HTTP::payload]" }
            set client_ip [IP::client_addr]
            set auth_string [HTTP::payload]
            regexp -nocase {form_username=(.*)&form_password=(.*)} $auth_string matchall auth_user auth_passwd_clear
            if { [CLASS::match $auth_user equals passwords] } {
                set stored_passwd [CLASS::match $auth_user equals passwords value]
                set auth_passwd_sha1 [sha1 $auth_passwd_clear]
                binary scan $auth_passwd_sha1 H* auth_passwd
                if { $auth_passwd eq $stored_passwd } {
                    set ::AUTHENTICATED "yes"
                } else {
                    HTTP::respond 200 content $::FORM_CONTENT
                }
            } else {
                HTTP::respond 200 content $::FORM_CONTENT
            }
        } else {
            HTTP::respond 200 content $::FORM_CONTENT
    }
}

when HTTP_RESPONSE {
    if { $::AUTHENTICATED eq "yes" } {
        persist add uie { $client_ip } 600
    }
}
