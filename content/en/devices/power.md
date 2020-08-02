---
title : Power Supplies
description : Power supply designs for all devices
date: 2020-01-18
categories: ["devices"]
keywords: [versions, ti, esp, power]
weight: 4003
draft: false
toc: true
linktitle: "Power Supplies"
menu:
  docs:
    parent: "devices"
    weight: 31
---


All devices will be mains powered. 

## TI CC3220S

The CC3220S needs a 3.3V DC power supply. There are numerous AC-DC pcb modules which make the power supply design quite simple.   

The existing design for a 3.3V from mains power supply is [here](https://github.com/m0vin/m0v-hw-pwrcon)

The design is based around [Meanwell's AC-DC pcb module](https://github.com/m0vin/m0v-hw-pwrcon/blob/master/docs/2547881.pdf)

The mains input consists of a fuse, choke, filter and varistor. 

{{< figure src="/images/devices/mainsin.png" caption="Mains" >}}

{{< figure src="/images/devices/psu.png" caption="PSU" >}}

The output of the AC-DC converter consists of further filters and over-voltage protection. 

{{< figure src="/images/devices/dcout.png" caption="DC Out" >}}

Also included on the same PCB is a simple continuity check circuit. 

{{< figure src="/images/devices/continuity.png" caption="Continuity check circuit" >}}

When current flows through D1, transistor Q1 turns on and powers the op amp circuit. When power is applied, the non-inverting input of U1A is biased at 40mV. The circuit under is biased at approx 4mA with the current flowing through LED D1. When the circuit under test (J1) is below 10Ω, the voltage developed is below 40mV so the op amp (wired as a comparator) outputs a positive signal and turns on the Green LED. 

```
V = I*R = 4mA * 10Ω = 40mV
```

The output of the op-amp is connected via J6 to the ADC of the CC3220S (pin 60).  

## MBus power supply

An [M-Bus master module](https://github.com/m0vin/m0v-hw-mbus-master) requires 36/37V DC power supply. 

Some designs use a boost (3.3 -> 36/37V) converter. Shown below is [one such design](https://github.com/m0vin/m0v-hw-mbus-master/tree/master/docs). 

{{< figure src="/images/devices/3-36vconverter.png" caption="Boost Converter" >}}

## Combined converter

Rather than having 2 separate power supplies (one to power the device at 3.3 and another for the MBus, a single converter can be designed with multiple voltage outputs (3.3 and 36/37V). 

This custom design reduces the component count/cost.
