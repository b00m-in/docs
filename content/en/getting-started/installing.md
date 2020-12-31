---
title: Install B00M
linktitle: Install B00M
description: Install B00M at the AC mains distribution board of your premises.
date: 2019-11-01
publishdate: 2019-11-01
lastmod: 2020-01-02
categories: [getting started,fundamentals]
authors: ["rcs"]
keywords: [install,m-bus,net-meter,spd]
menu:
  docs:
    parent: "getting-started"
    weight: 30
weight: 30
sections_weight: 30
draft: false
aliases: [/tutorials/installing/,/overview/installing/,/getting-started/install,/install]
toc: true
---

{{% note %}}
Installation should be carried out by a certified electrician or similar qualified professional. Not heeding warnings, if you choose to do it yourself make sure you turn off the mains MCB before trying the following connections.  
{{% /note %}}

B00M currently consists of 3 separate DIN rail mounted devices:

* Surge protection module
* Modbus capable net-neter module
* B00M WiFi/GPRS module

## Quick Install

### Surge protection module

This is connected in parallel with your electrical loads/PV system. Learn more about SPDs.

The NC/COM indicators on the SPD are connected to the B00M WiFi/GPRS module. 

### Net meter

This is connected in series with your electrical loads/PV system. The Modbus A, B ports are connected to the B00M WiFi/GPRS module. 

Learn more about net-meters. 

### B00M WiFi/GPRS module

This is a mains powered device also connected in parallel with your existing loads/PV system. It also receives connections from the other two modules. 

Learn more about the B00M WiFi/GPRS module. 


