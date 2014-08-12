#
# Copyright 2014, Michael J. Wheeler <mwheeler@a10networks.com>, A10 Networks
# Version 1.0 - 2014-08-11
#
# aFleX script to provide advanced rate-limiting options for DNS load balancing. Specifically
#   useful for mitigating DNS-based DDoS attacks without dropping or rejecting all traffic.
#   Users that are in remedation have their HTTP requests sent to a remediation server
#   giving instructions to fix their CPE device to not be an open relay. 
#
# Features include:
#  - Configurable rate limits per-user and per-domain queried
#  - Bypass mode for either per-user or per-domain lists
#  - Configurable whitelist for domains that will never be put into remediation
#  - Configurable remediation server for clients to be redirected to
#
# !!! NOTE !!!
# Thresholds MUST be configured before putting this script into production. The
#   limits supplied are easily reached for demonstration purposes only.
# A class list named DNS_OpenRelay_Whitelist must be created prior to loading this script.
# !!! NOTE !!!
#
# Configurables:
#  ::user_maxquery - Maximum number of queries user is allowed to issue within the given 
#       timeperiod before being put into remediation.
#  ::user_holdtime - Number of seconds that user will be in remediation before being allowed to
#       resume normal operations.
#  ::user_interval - Interval (in seconds) that user queries will be tracked. For instance, if
#       user_maxquery is 100 and user_interval is 10, the user will be allowed to issue 100
#       queries in a 10 second period before being put in remediation.
#  ::bypass_user_limits - Do not put users in remediation no matter how many queries issued. 
#  ::domain_maxquery - Maximum number of queries for a given domain that are allowed before
#       all queries for the domain will be sent to the remediation server.
#  ::domain_holdtime - Number of seconds that all queries for a given domain will be in remediation
#       before normal operations will resume.
#  ::domain_interval - Interval (in seconds) that queries for an individual domain will be tracked.
#  ::bypass_domain_limits - Do not put domains in remediation no matter how many queries issued.
#  ::dns_response_code - DNS reponse code to issue for non DNS "A" type queries when a domain or
#       user is in remediation. For instance, if user at IP 10.1.1.1 is in remediation, all A-type queries
#       will be responded to with the remediation server and all other query types will receive this response
#       code. The default (5) is "refused". See RFC2929, section 2.3 for a list of response codes:
#       http://tools.ietf.org/html/rfc2929#section-2.3 .
#  ::remediation_server_v4 - IPv4 address of a remediation server. This IP address will be returned
#       to any queries when an individual user or individual domain is in remediation.
#  ::debug - Enable (1) or Disable (0) debug logging .
#
when RULE_INIT {
  # parameters for individual user limiting
  set ::user_maxquery 10
  set ::user_holdtime 60
  set ::user_interval 10
  set ::bypass_user_limits 0

  # parameters for domain limiting
  set ::domain_maxquery 10
  set ::domain_holdtime 120
  set ::domain_interval 10
  set ::bypass_domain_limits 0

  # other parameters
  set ::remediation_server_v4 "192.168.1.1"
  set ::dns_response_code 5
  set ::debug 0
}

when DNS_REQUEST {
  set user_key [IP::client_addr]
  set domain_key [DNS::question name]

  # first, make sure the domain is not whitelisted
  if { [CLASS::match $domain_key "DNS_OpenRelay_Whitelist" dns] } {
    # domain is whitelisted. take no action and pass the query onto the service group
    if { $::debug } { log "$domain_key is whitelisted. Bypassing ruleset for $user_key." }
    return
  }
  
  # Check to see if the user is in the "bad users" table
  if { [table lookup "bad_users" $user_key] != "" && !$::bypass_user_limits } {
    if { $::debug } { log "User $user_key is currently in remediation." }
    if { [DNS::question type] eq "A" } {
      # for query type of "A" return the remediation server.
      DNS::answer clear
      DNS::answer insert [DNS::rr $domain_key 0 IN A $::remediation_server_v4] ; DNS::return
      return
    } else {
      # other query types, return NOERROR
      DNS::answer clear; DNS::header rcode $::dns_response_code ; DNS::return
      return
    }
  }

  # Check to see if the domain they are querying is in the "bad domains" table
  if { [table lookup "bad_domains" $domain_key] != ""  && !$::bypass_domain_limits } {
    if { $::debug } { log "Domain $domain_key is currently in remediation." }
    if { [DNS::question type] eq "A" } {
      # for query type of "A" return the remediation server.
      DNS::answer clear
      DNS::answer insert [DNS::rr $domain_key 0 IN A $::remediation_server_v4] ; DNS::return
      return
    } else {
      # other query types, return NOERROR
      DNS::answer clear; DNS::header rcode $::dns_response_code ; DNS::return
      return
    }
  }

  # Check to see if user is in the "known_users" table. If so, increment their query counter. If not, create
  #   them an entry in the table.
  if { [table lookup "known_users" $user_key] == "" } {
    # user does not have an entry in the known_users table. Create one.
    if { $::debug } { log "Creating a known_users entry for $user_key." }
    table set "known_users" $user_key 1 indef $::user_interval
  } else {
    # user currently has an entry in the known_users table. Increment the query counter.
    set user_count [table incr "known_users" -notouch $user_key]
    if { $::debug } { log "Incrementing known_users entry for $user_key. Count is currently $user_count ." }
    
    # check to see if the user has exceeded their query limit
    if { $user_count > $::user_maxquery } {
      # user has exceeded their individual query limit. Add them to the "bad users" table and remove them
      #   from the "known_users" table.
      if { !$::bypass_user_limits } {
        if { $::debug } { log "User $user_key has exceeded their individual query limit. Entering remediation." }
        table add "bad_users" $user_key 1 indef $::user_holdtime
        table delete "known_users" $user_key
      } else {
        if { $debug } {log "User $user_key has exceeded their individual query limit, but bypass user limits is enabled. NOT entering remediation for user." }
      }
    }
  }

  # Check to see if domain is in the "known_domains" table. If so, increment its query counter. If not, create
  #   it an entry in the table.
  if { [table lookup "known_domains" $domain_key] == "" } {
    # domain does not have an entry in the known_domains table. Create one.
    if { $::debug } { log "Creating a known_domains entry for $domain_key." }
    table set "known_domains" $domain_key 1 indef $::domain_interval
  } else {
    # domain currently has an entry in the known_domains table. Increment the query counter.
    set domain_count [table incr "known_domains" -notouch $domain_key]
    if { $::debug } { log "Incrementing known_domains entry for $domain_key. Count is currently $domain_count ." }
    
    # check to see if the domain has exceeded its query limit
    if { $domain_count > $::domain_maxquery } {
      # domain has exceeded its individual query limit. Add it to the "bad domains" table and remove it
      #   from the "known_domains" table.
      if { !$::bypass_domain_limits } {
        if { $::debug } { log "Domain $domain_key has exceeded its individual query limit. Entering remediation." }
        table add "bad_domains" $domain_key 1 indef $::domain_holdtime
        table delete "known_domains" $domain_key
      } else {
        if { $::debug } {log "Domain $domain_key has exceeded its individual query limit, but bypass domain limits is enabled. NOT entering remediation for domain." }
      }
    }
  }
}
