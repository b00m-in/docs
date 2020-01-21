---
title: OTA Updates
linktitle: OTA Updates
description: M0V supports OTA updates of device firmware.
date: 2020-01-18
publishdate: 2020-01-18
lastmod: 2020-01-18
categories: [devices]
keywords: [ota]
menu:
  docs:
    parent: "devices"
    weight: 150
weight: 150	#rem
draft: false
aliases: [/devices/ota/]
toc: true
---

The ability to update firmware of the devices OTA is very important for bug fixes and feature enhancements. 

> See [OTA Programming](https://en.wikipedia.org/wiki/Over-the-air_programming)

## How it works

When an update is available the server advertises it to the devices which then proceed to download the update while continuing to send routine data to the server. 

On successful download of the image, the devices then dis-connect from the access point, re-flash the image, re-start and re-connect themselves to successfully complete the OTA update.   

