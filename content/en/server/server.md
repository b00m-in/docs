---
title: M0V server
linktitle: Server
date: 18th May 2019
publishdate: 2019-05-18
lastmod: 2017-02-01
categories: [go, encryption]
keywords: [server, certificates]
menu:
  docs:
    parent: "server"
    weight: 10
weight: 20
sections_weight: 20
draft: false
aliases: [/server/server]
toc: true
---

### Brief

A secure (tls) tcp server to receive status/meter readings with postgresql database to store readings. Server uses acme for auto-generation and renewal of certificates.

The server is one part of four:

+ Data receipt server (this) - `locomov`
+ Data retrieval server - `finisher`
+ Device firmware - `provisioning_CC3220S_LAUNCHXL_tirtos_ccs`
+ Android app software - `SimpleLink_WiFi_Provisioning_Android_Source_2.2.257`

### [Server](#server){#server}

#### [log](#log){#log}

Stdout/stderr is piped to a modified version of funnel which writes and rotates log files. 

```
./mov-server -stderrthreshold=INFO -secure -dbdb=m0v -dbuser=sridhar -dbpw= 2>&1 | funnel -app=mov &
./mov-confo-server -stderrthreshold=INFO -secure -dbdb=m0v -dbuser=sridhar -dbpw= 2>&1 | funnel -app=confo &
``` 

`mov-confo-server has been deprecated by a handler in the data retrieval server `finisher` because  `mov-confo-server` consisted of only a single https handler for the retrieval of the hash of a newly configured device using `device_name` and `ssid`.

#### [data](#data){#data}

A packet sent from a device (publisher/pub) consists of:
```
Id int64 `json:"id!`
Timestamp int64 `json:"timestamp,omitempty"`
Status bool `json:"status"`
Voltage float64 `json:"voltage"`
Frequency float64 `json:"freq"`
//Lat float64 `json:"lat"`
//Lng float64 `json:"lng"`
```
`Id` (should be `pub_id`) is the id of the pub which is set during configuration with app along with the location and other system info (tbc). 

A packet saved to db is as follows with the `Timestamp` from the packet used as `created_at`:

```
pub_id INTEGER NOT NULL REFERENCES pub(pub_id),
id SERIAL PRIMARY KEY, 
created_at TIMESTAMPTZ NOT NULL default current_timestamp,
saved_at TIMESTAMPTZ NOT NULL default current_timestamp,
voltage REAL,
frequency REAL,
protected boolean NOT NULL,
```

`pub_id` is in the packet sent from a pub. `id` is an incrementing id of the packet saved to db. `created_at` is a timestamp 


### [Test client](#testclient){#testclient}

The client in `b00m_client.go` is a Go TCP client which connects to the TCP server with `tls.Config{InsecureSkipVerify:false}` to verify server certificate. It then posts a json packet and receives a `Thank you` reply from the server. 

### [Cloud Confirmation](#cloudconfirm){#cloudconfirm}

A second simple tcp+ssl server listening on another port (38979) provides the cloud confirmation to the Android (external configuration) app. 

The server accepts tokens from successfully provisioned devices and returns them (when queried) to the external configuration app which generated the tokens in the first place. 

+ The app connects to the cc3220s and provisions the device with ssid, password and a token. 
+ The device then connects to the cloud confirmation server and posts the token to confirm successful provisioning. 
+ The app then queries the cloud confirmation server for the token, upon receiving which the configuratiaon process is complete.  


```
type Confo struct {
    Devicename string`json:"deviceName"`
    Timestamp int64 `json:"timestamp,omitempty"`
    Ssid string `json:"ssid"`
    Hash int64 `json:"hash,omitempty"`
    Sub string `json:"email,omitempty"`
}
```
On receiving a confo, the server does the following: 
- check if `Sub` is known, i.e. registered email in `sub`
    - yes: check if `Hash` exists in `pub`
        - yes: check if `Sub.Id` == `creator` in `pub`
            - yes - ok save the confo in `confo` as the `sub` and `pub` hash pre-exist. 
            - no - conflict! save the confo in `cconfo` (will mean 2 subs have configured same `Hash` which is an unlikely event, sub will have to be informed to change devicename)
            - other - if `creator` in `Pub` is unpopulated, populate it with `Sub.Id`
        - no: create an entry in `pub` and save the confo in `confo`
    - no: save the email in `csub` table. check if `Hash` exists in `pub`
        - yes: ensure that `Sub.Id` != `creator` in `pub`
            - yes - ok save the confo
            - no - we've a problem - see other below. unpopulate `creator` in `pub`
            - other - if `creator` in `Pub` is unpopulated, it's left unpopulated (only registered emails in `sub` can be `creator`)

The confo gets saved anyway - either in `confo` or `cconfo`



### [Gotchas](#gotchas){#gotchas}

The following files are for obvious reasons not part of the respository:

```
b00m.in+rsa
b000m-trusted.chain.pem
b00m-trusted-key.pem
```

Certificate problems between client/server will usually result in an error on the server such as:

```
Error decoding JSON data tls: no cipher suite supported by both client and server
```

### [References](#references){#references}

+ [acme](https://godoc.org/golang.org/x/crypto/acme/)
+ [glog](https://godoc.org/github.com/golang/glog)
+ [funnel](https://github.com/agnivade/funnel)
+ [libpq](https://godoc.org/github.com/lib/pq)
+ [ti let's encrypt](https:////e2e.ti.com/support/wireless-connectivity/wifi/f/968/t/587690?tisearch=e2e-sitesearch&keymatch=letsencrypt) 
+ [](https://)

