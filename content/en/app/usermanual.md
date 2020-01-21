---
title: User Manual
linktitle: User Manual
description: M0V provisioing apps make the devices very easy to  install.
date: 2020-01-18
publishdate: 2020-01-18
lastmod: 2020-01-18
categories: [app]
keywords: [app]
menu:
  docs:
    parent: "app"
    weight: 150
weight: 150	#rem
draft: false
aliases: [/devices/ota/]
toc: true
---

The ability to provision/interact with the device using a mobile app allows for lower cost devices.

### Provisioning App

From a user perspective, the following steps should be followed using an Android device to configure the device to use. Configuring the device with a smart phone app reduces device production costs.

+ Download app from Play store
+ App connects to the device's (Access Point) AP.
+ User enters WAN AP SSID, password and press `Provision`.
+ `Provision` converts the device's AP to station (STA) and connects to WAN AP with SSID, password entered in previous step, exchanges unique hash (of device name, WAN SSID and user email) with server.
+ LED indicator on device appears solid if connection to AP/server successful. Otherwise LED indicator continues flashing once per second in AP mode awaiting provisioning.

See [Android dev setup](/tools/android) for detailed development setup.

### Viewing App

This is the customer facing app where a user can login and view status of SPD and meter reading data.
