#!/bin/sh

if [ -f "/init" ]; then
    /init &
fi

/usr/local/bin/jenkins-agent "$@"