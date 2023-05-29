---
title: Cloud-OTA
description: Description of OTA (Over-The-Air) Update.
date: 2020-01-16
layout: single
keywords: ["firmware", "ti", "ota"]
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

Details about the use of the [cloud-ota][] with B00MIN / Simplelink devices.

### Brief

Once connected to the broker and sending data, B00MIN devices receive a version number as response to every packet sent to the broker. When this version number is greater than the version of the application running on the device, an OTA update is initiated on the device.

#### [ota](#ota)

Firstly a new image is downloaded from the image server. Once the download is completed, if all checks are OK, the image is committed and run after the device resets itself. If there are errors the image is rolled back and the previous image continues running. Once committed, it's not possible to roll-back to the previous image. 


### Errors


OtaCheckAndDoCommit() must be called after a successful OTA. To accomodate this, on every call to SendPingToGW(), an OtaCheckAndDoCommit() is performed. If no commit is pending, it just returns immidiately so not an expensive call.  



## Demos




[sntp]: https://e2e.ti.com/support/wireless-connectivity/wifi/f/968/t/829406?tisearch=e2e-quicksearch&keymatch=sntp
[94fb658]: https://github.com/b00m-in/cc3220s/
[networking processor]: https://www.ti.com/lit/ug/swru455c.pdf
