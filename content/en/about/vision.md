---
title: Vision
linktitle: Vision
description: Not so random ideas about future of B00M.
date: 2020-01-13
publishdate: 2020-01-13
lastmod: 2020-01-13
keywords: [ssg,static,performance,security]
menu:
  docs:
    parent: "about"
    weight: 3
weight: 30
sections_weight: 30
draft: false
aliases: []
toc: false
---

The vision is intentionally broad and diverse. Most ideas in the vision may sound like `solutions` looking for `problems`, but so be it. After all, it's a `vision`.  All this `vision` on the back of a simple idea of monitoring the state of a NO/NC to protect PV inverters!

* PV Roof Tile 

* Captive consumption / appliance control

* Weather stations


## PV Roof Tile

A roof is an exposed, inaccessible surface which makes maintenance difficult when faults occur. For PV roof tiles to gain widespread adoption, tile(s) level monitoring is essential at whatever resolution to pin-point problems. A very low cost DC PLC device is the only feasible way forward. 

##  Appliance Control

A net-meter at the grid-interconnection point allows more captive consumption by switching on/off loads as production increases/decreases. Appliances (like pumps and washing machines) need to be either retro-fitted or built with some ability to communicate with a gateway-like device (B00M). Ideally communication with appliances is also via low cost PLC modems to avoid expensive radios. 

An appliance like a washing machine is loaded in the morning and set to `Ready` by a user. The appliance then communicates its readiness to B00M and receives a message to switch on when optimal. After the load is done, it then goes back to a `Sleep` mode and ignores any further message to switch on unless reset to `Ready` by a user.  

## Weather stations

The next step in appliance control will be the ability to use weather data (NN/ML?) to predict optimal times to turn on long running loads (eg. washing machine) which can't be switched off mid-way.
