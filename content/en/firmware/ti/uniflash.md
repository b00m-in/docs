---
title: Uniflash
description: Uniflash usage.
date: 2020-01-16
keywords: ["firmware", "ti", "uniflash"]
menu:
  docs:
    parent: "firmware_ti"
    weight: 30
weight: 40
sections_weight: 5
draft: false
aliases: [/firmware/ti/uniflash]
toc: true
---

Uniflash is a standalone flash tool for TI MCUs and SimpleLink devices (CC3220S/CC3235). 

Download from [product page][]

## Install


Install as root:

```
sudo ./uniflash_sl.4.6.0.2176.run // install to /opt/ti
```

Start Uniflash:

```
cd /opt/ti/uniflash_4.6.0
sudo ./node-webkit/nw
```

## Usage

Once running, follow instructions in Section 3.4 of [Getting Started][] with CC3220S to use Uniflash to flash signed images onto the device's storage.

When flashing a secure device like CC3220S, a certificate (and associated private key) is required. This certificate must be signed by a CA whose certificate in turn must be signed by a Trusted Root CA whose certificate is on the limited list of common trusted root CAs used by TI. See [Lets Encrypt][] and [B00M Server][] for details about cerificate generation. 

## Gotchas

As per the problem related in [sntp][], the service pack needs to be included while using Uniflash to flash the image otherwise a -202 (sntp module error) is encountered.

[product page]: http://www.ti.com/tool/Uniflash
[Getting Started]: http://www.ti.com/lit/ug/swru461b/swru461b.pdf
[sntp]: https://e2e.ti.com/support/wireless-connectivity/wifi/f/968/t/829406?tisearch=e2e-quicksearch&keymatch=sntp
[Download]: http://processors.wiki.ti.com/index.php/Category:CCS_UniFlash
[Lets Encrypt]: /tools/letsencrypt
[B00M Server]: /server/encrypt
