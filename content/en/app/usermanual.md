---
title: User Manual
linktitle: User Manual
description: B00M provisioing apps make the devices very easy to  install.
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

From a user perspective, the following steps should be followed using an Android device to provision (configure) the device to use.

+ Download provisioning app from [Play Store][] on an Android 10+ device. 
+ Start the provisioning app and allow the requested permissions (location, Wifi, external storage etc.)
+ STEP 1: Login/Register to [B00MIN][] on the provisioning app. The provisioning app will record the SSID of the Wifi Access Point (AP) it uses to connect to the internet (startingSSID).

{{< figure src="/images/app/step1.png" caption="Step 1 Login/Register" >}}

+ STEP 2: Power up B00MIN device which starts in AP mode with blinking red LED. Refresh scan on provisioning app which will find the B00MIN device and prompt the user to connect to it. The provisioning app should dis-connect from the startingSSID AP and connect to the device's AP.

{{< figure src="/images/app/step2.png" caption="Step 2 Choose device to use with app" >}}

+ STEP 3: Enter a new device name and the SSID and password of the startingSSID AP and press the `Start Config` button which becomes activated and the provisioning process can be started. 


+ STEP 4: Pressing `Start Config` sends the device all the data it requires to connect to the internet. Once received, the device swaps into station (STA) mode and connects to startingSSID with password entered in previous step. It then exchanges unique hash (of device name, WAN SSID and user email) with B00MIN server which registers the device as owned by the registered user logged into the provisioning app. Goes without saying that the password of SSID is not exposed/shared or stored anywhere else but on the device. Note that the `Start Config` button is disabled if user is not logged in.

{{< figure src="/images/app/step4.png" caption="Step 4 Start provisioning" >}}

+ STEP 5: The provisioning app disconnects from the device, re-connects to `startingSSID` and performs an MDNS scan to confirm that the device has indeed connected to `startingSSID`. If the device is found, the provisioning app declares success and finishes the provisioning process. If not found, something in the provisioning process has gone wrong and the provisioning app will display an error to the user. LED indicator on device appears solid if connection to AP/server successful. Otherwise LED indicator continues blinking once per second in AP mode awaiting provisioning.

{{< figure src="/images/app/step5.png" caption="Step 5 Confirmation" >}}

+ STEP 6: 

Once the device sends a packet to the server, the system that this device monitors can then be set up at [B00MIN][]. Alerts can also be set up. 

{{< figure src="/images/app/step6.png" caption="Step 6 Enter System Details" >}}

+ STEP 7: If/when required the SSID/PSWD on the device can be changed by pressing the (only) button on the device. The device forgets the old SSID/PSWD and re-enters AP mode ready to be re-provisioned again starting from Step 1.

{{< figure src="/images/app/step7.png" caption="Step 7 Re-provision" >}}

See [Android dev setup](/tools/android) and the [Developer Manual](/app/devmanual) for detailed development setup and details about app.

### Viewing App

This is the customer facing app where a user can login and view status of SPD and meter reading data.


[Play Store]: https://play.google.com/store/apps/details?id=in.b00m.smartconfig
[B00MIN]: https://pv.b00m.in/subs
