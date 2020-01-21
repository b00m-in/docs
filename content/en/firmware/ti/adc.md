---
title: ADC
linktitle: ADC Usage
description: TI ADC usage.
date: 2020-01-16
keywords: ["firmware", "ti", "adc"]
layout: single
menu:
  docs:
    parent: "firmware_ti"
    weight: 3
weight: 40
sections_weight: 5
draft: false
aliases: [/firmware/ti/adc]
toc: true
---

### ADC

ADC1 = pin 60

### MOV

The SPD that the CC3220S will connect has a mechanical relay that gets triggered when the thermal fuse burns out. So the normally open (NO) becomes closed and the normally closed (NC) becomes open. 

A simple continuity check circuit is used to check the state of NO. When the thermal fuse hasn't burned out, the transistor doesn't conduct (as theres no base current as the circuit is open) and the comparator ouputs low as its inverting input is lower. 

When the thermal fuse burns out and NO is now closed, the transistor conducts and the comparator ouputs high as its inverting input is higher. 

The output of the comparator can be fed to either the ADC or GPIO of the CC3220S. 

