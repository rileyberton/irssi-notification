#!/bin/bash

TITLE=$2
MESSAGE=$1

/Users/rberton/bin/terminal-notifier.app/Contents/MacOS/terminal-notifier -title irssi -message "$MESSAGE" -subtitle "$TITLE" 2>&1>/dev/null

