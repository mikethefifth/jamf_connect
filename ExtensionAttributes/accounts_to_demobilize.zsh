#!/bin/zsh

## Builds a list of remaining mobile accounts on the Mac.
## Used as a Jamf Pro extension attribute to determine if Demobilize has completed.

MOBILEACCOUNTSLIST=`dscl . list /Users OriginalNodeName | awk '{print $1}' 2>/dev/null`
if [ "$MOBILEACCOUNTSLIST" == "" ]; then
        echo "<result>No remaining mobile accounts.</result>"
else
        echo "<result>$MOBILEACCOUNTSLIST</result>"
fi
exit 0