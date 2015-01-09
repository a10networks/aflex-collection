#
# Bind this aFleX to a virtual-server on port 80 http to have all requests
# redirected to https.
#
# The argument to HTTP::redirect is limited to 255 chars. If the function is
# supplied an argument longer than this limit the aFleX is aborted.
# Here's a workaround using HTTP::respond which doesn't have this limitation.
# Tested on ACOS 2.7.2-P3-SP5. Use at your own risk.
#
# License: public domain
#
when HTTP_REQUEST {
    HTTP::respond 302 Location "https://[HTTP::host][HTTP::uri]"
}
