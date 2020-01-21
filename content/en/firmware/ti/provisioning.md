---
title: Provisioning
description: Provisioning Code Review.
date: 2020-01-16
layout: single
keywords: ["firmware", "ti", "provision"]
menu:
  docs:
    parent: "firmware_ti"
    weight: 4
weight: 40
sections_weight: 5
draft: false
aliases: [/firmware/ti/provision]
toc: true
---

### Empty

Provisioning using external confirmation/feedback

From swru455g (16.8.1):

To use a cloud-based feedback, the external confirmation bit should be set in the provisioning host command flags parameter when the provisioning process is started.

```
sl_WlanProvisioning(SL_WLAN_PROVISIONING_CMD_START_MODE_APSC, ROLE_AP, 600, NULL, SL_WLAN_PROVISIONING_CMD_FLAG_EXTERNAL_CONFIRMATION);
```

Can only use the above with `ROLE_STA` as second argument because it needs to be in station mode and connect to an external server to confirm connection. 



### Provisioning

Each of 7 states has 12 event handlers (function pointers) and corresponding next state defined by lookup/transition table `const Provisioning_TableEntry_t gTransitionTable[7][12]` 

7 AppState(s): 
```
0 STARTING 
1 WAITING_FOR_CONNECTION
2 WAIT_FOR_IP
3 PINGING_GW  
4 PROVISIONING_IN_PROGRESS 
5 PROVISIONING_WAIT_COMPLETE
6 ERROR
7 MAX
```
12 AppEvent(s):
```
0 STARTED 
1 CONNECTED
2 IP_ACQUIRED 
3 DISCONNECT
4 PING_COMPLETE 
5 PROVISIONING_STARTED 
6 PROVISIONING_SUCCESS 
7 PROVISIONING_STOPPED 
8 PROVISIONING_WAIT_CONN
9 TIMEOUT 
10 ERROR 
11 RESTART
12 MAX
```
17 event handlers (function pointers) of the form: 
```
typedef int32_t (*fptr_EventHandler)(void); 
``` 
For instance: 
```
int32_t StartConnection(void);                 // SC
int32_t HandleWaitForIp(void);                 // HWI
int32_t ProvisioningStartRequest(void);        // PS
int32_t ProvisioningRestartRequest(void);      // PRR
int32_t ReportError(void);                     // RE
int32_t DoNothing(void);                       // DN
int32_t CheckLanConnection(void);              // CLC
int32_t CheckInternetConnection(void);         // CIC
int32_t HandleProvisioningComplete(void);      // HPC
int32_t HandleProvisioningTimeout(void);       // HPT
int32_t HandleUserApplication(void);           // HUA
int32_t SendPingToGW(void);                    // SPG
```

|State/Event| 0    | 1    | 2    | 3    | 4    | 5    | 6    | 7    | 8    | 9    | 10   | 11   |
|-----------|------|------|------|------|------|------|------|------|------|------|------|------|
| 0         |SC->1 |HWI->2|RE->6 |RE->6 |RE->6 |RE->6 |RE->6 |RE->6 |RE->6 |RE->6 |RE->6 |PS->4 |
| 1         |SC->1 |HWI->2|RE->6 |SC->1 |HPC->3|PS->4 |DN->1 |CLC->1|DN->1 |PS->4 |PS->4 |PRR->1|
| 2         |PS->4 |RE->6 |CLC->3|SC->1 |DN->2 |PS->4 |DN->2 |HPC->3|DN->2 |RE->6 |RE->6 |PRR->1|
| 3         |DN->3 |HWI->2|CIC->3|HD->1 |DN->3 |PS->4 |DN->3 |HUA->3|DN->3 |SPG->3|RE->6 |PRR->1|
| 4         |PSR->4|HC->4 |CIC->4|HD->4 |DN->4 |DN->4 |HPC->5|HPC->3|DN->1 |PRR->1|RE->6 |PRR->1|
| 5         |DN->5 |DN-->5|DN->5 |HD->5 |DN->5 |DN->5 |DN->5 |HUA->3|DN->1 |HPT->5|RE->6 |PRR->5|
| 6         |RE->1 |RE-->1|RE->1 |RE->1 |RE->1 |RE->1 |RE->1 |RE->1 |RE->1 |RE->1 |RE->1 |PS->1 |

```
S0->E0->SC->S1
S1->E1->HWI->S2
S2->E2->CLC->S3->E7(from CLC)->HUA->3
OR 
S2->E7->HPC->S3
S3->E9->SPG->S3->E9 ... repeat
```

4 thread are created:
```
RetVal = pthread_create(&gSpawnThread, &pAttrs_spawn, sl_Task, NULL);
RetVal = pthread_create(&gProvisioningThread, &pAttrs, ProvisioningTask, NULL);
RetVal = pthread_create(&gDisplayThread, &pAttrs_display, UpdateLedDisplay, NULL);
RetVal = pthread_create(&gAdcThread, &pAttrs_adc, adcThread, NULL);
```

The `ProvioningTask` thread creates a message queue `gProvisioningSMQueue` and receives from this queue:
```
gProvisioningSMQueue = mq_open("SMQueue", O_CREAT, 0, &attr);
...
while(1) {
    mq_receive(gProvisioningSMQueue, (char *)&event, 1, NULL);
    ...
}
```
The SL event handlers `SimpleLinkWlanEventHandler/SimpleLinkNetAppEventHandler` and the application event handlers send to this queue using function `SignalEvent`. 
```
int16_t SignalEvent(AppEvent event) {
    ...
    mq_send(gProvisioningSMQueue, &msg, 1, 0);
    ...
}
```

Both `ProvisioningTask & adcThread` create timers using sigevent.

The `adcThread` also blocks on a semaphore which gets posted to when the timer expires.

### MOV

The SPD that the CC3220S will connect has a mechanical relay that gets triggered when the thermal fuse burns out. So the normally open (NO) becomes closed and the normally closed (NC) becomes open. 
