#!/bin/bash

# Run via screen as a quick workaround to 
# "open /dev/tty: No such device or address" errors from apps,
# which in itself can cause some apps to return positive exit codes.
screen -D -m bin/pandafe $@
