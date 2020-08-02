---
title: M-Bus
linktitle: M-Bus
description: M0V is an M-Bus master.
date: 2020-01-18
publishdate: 2020-01-18
lastmod: 2020-01-18
categories: [learning]
keywords: [mbus, m-bus]
menu:
  docs:
    parent: "learning-resources"
    weight: 150
weight: 150	#rem
draft: false
aliases: [/learning/mbus/, /learning/m-bus]
toc: true
---

Principles of operation of [M-Bus][] are quite simple. The most relevant parts are:

{{% note %}}
In order to realize an extensive bus network with low cost for the transmission medium, a two-wire cable was used together with serial data transfer. In order to allow remote powering of the slaves, the bits on the bus are represented as follows:
{{% /note %}}

{{% note %}}
The transfer of bits from master to slave is accomplished by means of voltage level shifts. A logical “1” (Mark) corresponds to a nominal voltage of +36 V at the output of the bus driver (repeater), which is a part of the master; when a logical “0” (Space) is sent, the repeater reduces the bus voltage by 12 V to a nominal +24 V at its output.
{{% /note %}}

{{% note %}}
Bits sent in the direction from slave to master are coded by modulating the current consumption of the slave. A logical “1” is represented by a constant (versus voltage, temperature and time) current of up to 1.5 mA, and a logical “0” (Space) by an increased current drain requirement by the slave of additional 11-20 mA. The mark state current can be used to power the interface and possibly the meter or sensor itself.
{{% /note %}}

Most devices implemented as slaves seem to use a baud rate of between 2,400 and 9,600. There are few master modules available without implementation details:

[Master][] is module that can be used with a master or slaves. 
[Solvimus][] sells the MBUS-M13-S, a compact master level converter UART (TTL) to M-Bus for €50 but only to OEM customers. 

## Simulation

Here's a potential circuit for a module that converts the modulation of current consumed by a slave to UART RX and secondly shifts a UART TX signal to the desired M-Bus voltage levels (36V and 24V) used to send data to slaves. This circuit could potentially work for upto 3 slaves on the same bus.    

{{< figure src="/images/learning-resources/mbus_spice.png" caption="Spice sim" >}}

To simulate master sending bits to slave, V2 is pulsed between 0 and 5V.

{{< figure src="/images/learning-resources/mbus_spice_voltage_tx.png" caption="Drive TX" >}}

When V(tx) is high, V(Q3C) (and so V(Q2b)) is pulled low causing the voltage at Q1 and Q2's base to be pulled lower (24V from 36V). Q1 & Q2 form a push pull emitter follower whose output will follow the (common) input to their bases. The 560Ώ resistor acts as a bias for better thermal stability and perhaps to avoid crossover distortion. 

To simulate slave sending bits to master, I1 is pulsed between 0 and 20mA.

{{< figure src="/images/learning-resources/mbus_spice_current_rx.png" caption="Read RX" >}}

I(Q1c) is in sync with current through the slave (I(I1)). When current is 20mA, there is a small voltage drop across R2 (V(n003)) that the current draw causes which causes Q4 to turn on. This then forward biases Vbe on Q5 and pulls V(rx) low. 

## Hardware

Kicad schematic and gerbers available on [Github][].


## References

[M-Bus]: https://m-bus.com/documentation-wired/04-physical-layer
[Master]: https://www.aliexpress.com/item/32853884383.html
[Solvimus]: https://www.solvimus.de/en/m-bus-products/
[Github]: https://github.com/m0vin/m0v-hw-mbus-master
