#!/bin/bash
##############################################################################
# A script to collect the version of Jamf Connect Login installed.           #
# If Jamf Connect Login is not installed "Not Installed" will return back  	 #
##############################################################################

NOT_INSTALLED="Not Installed"
RESULT=""

if [ -a /Library/Security/SecurityAgentPlugins/JamfConnectLogin.bundle/Contents/Info.plist ]
  then
    RESULT=$( /usr/bin/defaults read /Library/Security/SecurityAgentPlugins/JamfConnectLogin.bundle/Contents/Info.plist CFBundleShortVersionString )
else
    RESULT="$NOT_INSTALLED"
fi
/bin/echo "<result>$RESULT</result>"