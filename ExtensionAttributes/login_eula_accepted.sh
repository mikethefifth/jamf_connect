#!/bin/sh
EULA=$(ls /filepath/to/EULArecord/)

if [ $EULA == "" ]; then
   echo "<result>No EULA</result>"
else
   echo "<result>$EULA</result>"
fi