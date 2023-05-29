---
title: Server Overview
linktitle: Server Overview
date: 2023-04-06
publishdate: 2023-04-06
lastmod: 2023-04-06
categories: [overview, server, software]
keywords: [server, certificates, tls, envoyproxy, gin]
menu:
  docs:
    parent: "server"
    weight: 20
weight: 10
sections_weight: 20
draft: false
aliases: [/server/overview]
toc: true
---

{{< figure src="/images/server/arch.svg" caption="Server overview" >}}

### envoyproxy

B00MIN uses [envoyproxy](https://envoyproxy.io) as front (reverse) proxy. Envoyproxy enables use of dynamic secret and route discovery.

### broker

A simple secure (tls) tcp [server/broker](https://github.com/b00m-in/broker)to receive status/meter readings/packets from devices with postgresql database to store readings. 

### gin

Contains a simple [gin](https://github.com/gin-gonic/gin) server, router and and templates for display of data.

### xds
[XDS](https://github.com/b00m-in/xds) encapsulates a [grpc xds server](https://github.com/envoyproxy/go-control-plane) which can be used to publish secrets and routes to envoyproxy.

This can be used to enable gin to create a new snapshot cache of it's routes with a new `version` string and publish as an RDS (route discovery service) every time it's rebuilt which envoyproxy can then be configured to dynamically load whenever new routes/endpoints/clusters are available or old ones are disabled. 

### certman

certman consists of the following 3 components:

+ [serverx](https://github.com/b00m-in/crypto/serverx) has an acme client and responds to acme/tls-1 (tls-alpn-01) challenges. It also has a goroutine that stats the cert bundles every 600s (configurable) and splits newly generated/received bundles into certs and keys. 

+ [clientx](https://github.com/b00m-in/crypto/clientx)watches the certs directory and checks for expired or close-to-expiry (within the next 10 days non-configurable set in util/x509.go) certificates and makes requests to serverx with the sni of these certs. It does this every hour (currently non-configurable). If the cert's `NotAfter` time before 10 days into the future `if cert.NotAfter.Before(time.Now().AddDate(0,0,10))` the cert is expired or within 10 days to expiry. This forces serverx's acme client to make a request to letsencrypt to renew the cert because serverx is run with `RenewBefore` set to 480 hours (20 days). serverx then handles the alpn (acme/tls-s) challenge from letsencrypt and downloads the cert bundles. A serverx goroutine stats the cert directory every 600 seconds (10 minutues configurable) and watches for changes in any of the cert bundles and splits the bundle into cert chains and keys and saves them to new separate directories/files.

+ [sds_server](https://github.com/b00m-in/crypto/sds) reads these certs and keys from file, creates a snapshot cache and makes them available to envoy via SDS. It also refreshes the snapshot cache every 1 hour (non-configurable) with a new version string so that envoy updates it's config every 10 minutes. This is probably overkill for certs/keys which change only once every 90 days but whatever. [envoyproxy](https://envoyproxy.io) is configured to use certs/keys from sds_server's SDS and also forward acme/tls-1 requests to serverx. 

### otaserver

This service serves the latest firmware image available for devices to download. 

Once connected to the broker and sending data, B00MIN devices receive a version number as response to every packet sent to the broker. When this version number is greater than the version of the application running on the device, an OTA update is initiated on the device.

Firstly a new image is downloaded from the image server. Once the download is completed, if all checks are OK, the image is committed and run after the device resets itself. If there are errors the image is rolled back and the previous image continues running. Once committed, it's not possible to roll-back to the previous image. 

See [TI firmware](https:/b00m.in/docs/firmware/ti/wifi) for more details.

### summarise

This service summarises data in table `packet` into data in tables `hourly`, `daily` and `monthly`. 

Data from devices arrives every 2 minutes and is stored in table `packet`. This service queries data for all pubs from table `packet` every hour. It notes the max/min/ave voltage/frequency for each pub and stores it in table `hourly` along with the last available import/export active/reactive/total readings. Once a day, it uses the data from table `hourly` to populate table `daily` and once a month it uses the data from `daily` to populate table `monthly`. 

Note on timezones: `sub` has ability to choose/change timezone for `pub` in `pubconfig` which over-writes any location info that the device sends. Care should be taken to manage timezones when populating summary tables.  

When the monthly summary is being done, `packet` data from the previous monthly summary, i.e. `packet` data which is more than a month old at the time of doing the monthly summary is deleted from `packet`. Something will need to be done about the SERIAL column in `packet` which is ever-incrementing. How should it be reset or is it even needed?

###
