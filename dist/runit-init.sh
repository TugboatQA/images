#!/bin/bash

sv_stop() {
    for s in /etc/service/*; do
        "$RUNITDIR"sv stop "$s"
    done
}

# This should effectively be the same as setting SIGCHLD handler to SIG_IGN,
# which allows for the kernel to reap child processes that terminate.
trap "" SIGCHLD

trap "sv_stop; exit" SIGTERM

SVWAIT=60 "$RUNITDIR"runsvdir -P /etc/service &
wait
