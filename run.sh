#!/bin/sh
hugo serve --bind 0.0.0.0 --port 9090 --renderToDisk=true --memstats=memstats.log --meminterval=10s --logFile="log/logfile" --disableLiveReload & #--secure


