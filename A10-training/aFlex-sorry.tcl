#
# Copyright 2017, A10 Networks.
# Version 1
#
# Example HTTP Sorry page
#
# Scalability of this aFleX is unknown.
#
when LB_FAILED {
HTTP::respond 200 content "<html><head><title>Sorry</title></head><body><h1>We
are sorry, but the site you are looking for is temporarily in maintenance. Please try again soon.</h1></body></html>"
}
