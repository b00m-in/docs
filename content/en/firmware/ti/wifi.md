---
title: WiFi
description: TI WiFi usage.
date: 2020-01-16
layout: single
keywords: ["firmware", "ti", "wifi"]
menu:
  docs:
    parent: "firmware_ti"
    weight: 4
weight: 40
sections_weight: 5
draft: false
aliases: [/firmware/ti/wifi]
toc: true
---

Details about the use of the [networking processor][] of SimpleLink devices.

### Networking

When starting with the `empty` project and adding in Simplelink, add the `Library Path` and library`ccs/rtos/simplelink.a` in the project properties in C/C++ General -> Paths and Symbols. 

Then implement all the required callback functions (`SimpleLinkNetAppRequestMemFreeEventHandler`, `SimpleLinkNetAppRequestEventHandler`, `SimpleLinkWlanEventHandler`, `SimpleLinkGeneralEventHandler`, etc. etc.).

The host controls ths provisioning process using one command: 
{{< code file="provisioning.c" >}}
_i16 sl_WlanProvisioning(_u8 ProvisioningCmd, _u8 RequestedRoleAfterSuccess, _u16 InactivityTimeoutSec, char *pSmartConfigKey, _u32 Flags);
{{< /code >}}

RequestedRoleAfterSucess: The desired role (AP or STA) to which the device should switch if provisioning is successful (relevant only if the value of the ProvisioningCmd is 0, 1, 2, or 3).

InactivityTimeoutSec: Defines the period of time (in seconds) the system waits before it automatically stops the provisioning process when no user activity is detected. Relevant only if the value of the
ProvisioningCmd command is 0, 1, 2, or 3.

Flags: Optional configuration conducted by a bitmap.

| Command        |         Value                |                            Action                                  |
|:--------------:|:----------------------------:|:------------------------------------------------------------------:|
| BIT_0          | ENABLE_EXTERNAL_CONFIRMATION | Defines whether to use external confirmation or not. Relevant only |
|                |                              | if the value of the ProvisioningCmd command is 0, 1, 2, or 3.      |

Example usage: 
{{< code file="provisioning.c" >}}
retVal = sl_WlanProvisioning(provisioningCmd, ROLE_STA, PROVISIONING_INACTIVITY_TIMEOUT, NULL, SL_WLAN_PROVISIONING_CMD_FLAG_EXTERNAL_CONFIRMATION)`
{{< /code >}}

#### [sntp](#sntp){#sntp}

As per the problem related in [sntp][], the service pack needs to be included while using Uniflash to flash the image otherwise a -202 (sntp module error) is encountered.

Network time issue fixed in [94fb658][]

{{< code file="provisioning.c" >}}
struct tm netTime;
...
status = ClockSync_get(&netTime); // tm's months run from 0->11
SlDateTime_t dateTime = {0};
...
dateTime.tm_mon = netTime.tm_mon + 1; // but SlDateTime's months run from 1->12
{{< /code >}}


### Errors

Error codes can be found at:
```
source/ti/driver/net/wifi/errors.h
```
## TIRTOS

~/ti/tirtos_simplelink_2_13_01_09

Corresponding xdctools installed at:
~/ti/xdctools_3_31_01_33_core

This can be found by checking the install log which strangely has Windows paths:
./tirtossimplelink_2_13_01_09_install.log:Unpacking C:\ti\xdctools_3_31_01_33_core\jre\bin\dtplugin\deployJava1.dll
 
TIRTOS can be rebuit after changing Windows paths to Linux paths in tirtos.mak:
../xdctools_3_31_01_33_core/gmake -f tirtos.mak all

Also can choose compiler/linker options (CCS, GCC or IAR) in tirtos.mak

## Demos

wlanconnect -s "M0V" -t WPA/WPA2 -p "53606808"
send -c 192.168.1.100 -n 1

## OOB

provisioningTask
linkLocalTask: 
controlTask: handles button presses etc.
otaTask

[sntp]: https://e2e.ti.com/support/wireless-connectivity/wifi/f/968/t/829406?tisearch=e2e-quicksearch&keymatch=sntp
[94fb658]: https://github.com/m0vin/m0v-cc3220s/
[networking processor]: https://www.ti.com/lit/ug/swru455c.pdf
