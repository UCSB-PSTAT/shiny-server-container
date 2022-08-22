#!/bin/sh
exec xtail /var/log/shiny-server/ &
shiny-server 2>&1
