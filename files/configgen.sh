#!/bin/bash

# device type
isTablet=`adb shell getprop ro.build.characteristics | grep tablet`
isTv=`adb shell getprop ro.build.characteristics | grep tv`

# abi
arm=`adb shell getprop ro.product.cpu.abi | grep arm`

# version
ANDROID_VERSION=`adb shell getprop | grep -m 1 ro.build.version.release |  sed 's/^.*:.*\[\(.*\)\].*$/\1/g'`

# display size
info=`adb shell dumpsys display | grep -A 20 DisplayDeviceInfo`
width=`echo ${info} | sed 's/^.* \([0-9]\{3,4\}\) x \([0-9]\{3,4\}\).*density \([0-9]\{3\}\),.*$/\1/g'`
height=`echo ${info} | sed 's/^.* \([0-9]\{3,4\}\) x \([0-9]\{3,4\}\).*density \([0-9]\{3\}\),.*$/\2/g'`
density=`echo ${info} | sed 's/^.* \([0-9]\{3,4\}\) x \([0-9]\{3,4\}\).*density \([0-9]\{3\}\),.*$/\3/g'`
let widthDp=${width}/${density}
let heightDp=${height}/${density}
let sumW=${widthDp}*${widthDp}
let sumH=${heightDp}*${heightDp}
let sum=${sumW}+${sumH}

if [[ $softwarebuttons ]]
then
    HARDWAREBUTTONS=false
else
    HARDWAREBUTTONS=true
fi

if [[ $isTablet ]]
then
    DEVICETYPE='Tablet'
elif [[ $isTv ]]
then
    DEVICETYPE='TV'
else
    DEVICETYPE='Phone'
fi

if [[ $arm ]]
then
    ABI='ARM'
else
    ABI='X86'
fi

if [[ ${sum} -ge 81 ]]
then
    DISPLAYSIZE=10
else
    DISPLAYSIZE=7
fi

if [[ ${ANDROID_VERSION} == 4* ]] || [[ ${ANDROID_VERSION} == 5* ]] || [[ ${ANDROID_VERSION} == 6* ]]
then
    export AUTOMATION_NAME='Appium'
else
    export AUTOMATION_NAME='uiautomator2'
fi

if [[ -z $HOST ]]; then
    # calculate current HOST name only if HOST is missed
    HOST=`awk 'END{print $1}' /etc/hosts`
fi

cat << EndOfMessage
{
  "capabilities":
      [
        {
          "version":"${ANDROID_VERSION}",
          "maxInstances": 1,
          "platform":"ANDROID",
          "deviceName": "${DEVICENAME}",
          "deviceType": "${DEVICETYPE}",
          "platformName":"ANDROID",
          "platformVersion":"${ANDROID_VERSION}",
	  "udid": "${DEVICEUDID}",
	  "adb_port": ${ADB_PORT},
	  "proxy_port": ${PROXY_PORT},
	  "vnc": "${STF_PUBLIC_HOST}:${MAX_PORT}",
          "vncLink": "${SOCKET_PROTOCOL}://${STF_PUBLIC_HOST}:${MAX_PORT}",
          "automationName": "${AUTOMATION_NAME}"
        }
      ],
  "configuration":
  {
    "proxy": "com.zebrunner.mcloud.grid.MobileRemoteProxy",
    "url":"http://${HOST}:${PORT}/wd/hub",
    "port": ${PORT},
    "host": "${HOST}",
    "hubHost": "${SELENIUM_HUB_HOST}",
    "hubPort": ${SELENIUM_HUB_PORT},
    "maxSession": 1,
    "register": true,
    "registerCycle": 5000,
    "cleanUpCycle": 5000,
    "timeout": 180,
    "browserTimeout": 0,
    "nodeStatusCheckTimeout": 5000,
    "nodePolling": 5000,
    "role": "node",
    "unregisterIfStillDownAfter": 60000,
    "downPollingLimit": 2,
    "debug": false,
    "servlets" : [],
    "withoutServlets": [],
    "custom": {}
  }
}
EndOfMessage
