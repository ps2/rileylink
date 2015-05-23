#!/bin/sh

#sdcc -I. listen.c -o output/listen.hex && \
#cc-tool --log install.log -ew output/listen.hex

sdcc -I. convo.c -o output/convo.hex && \
cc-tool --log install.log -ew output/convo.hex
