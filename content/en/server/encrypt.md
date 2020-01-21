---
title: Encryption
linktitle: Encryption
date: 2020-01-19
publishdate: 2020-01-19
lastmod: 2020-01-19
categories: [go, encryption]
keywords: [server, certificates, tls]
menu:
  docs:
    parent: "server"
    weight: 20
weight: 10
sections_weight: 20
draft: false
aliases: [/server/encrypt]
---

### tls

Let's Encrypt uses DST as root (DST Root CA X3). This root CA (DST) is luckily in the list of common trusted root CAs used by the CC3220S. So download the [root certificate](https://www.identrust.com/dst-root-ca-x3) and append it to the chain loaded by server like below (use it as b00m-trusted-root.pem).

Certificate chains are loaded leaf first. So create a certificate chain in the following order:

```
b00m-trusted-cert.pem + b00m-trusted-ca-cert.pem + b00m-trusted-root.pem = b00m-trusted-chain.pem
```
And load it like this:

```
b00m, err := tls.LoadX509KeyPair("b00m-trusted-chain.pem", "b00m-trusted-cert-key.pem")
// handle err
config := &tls.Config {
        Certificate: []tls.Certificate{b00m},
        ...
} 
```

The CC3220S which is a TCP client to this server only permits the use of RSA certificates and keys. The acme default is now ec (elliptic curve). So to force acme to issue a rsa certificate, create a transport with `tls.TLS_RSA_WITH_AES_256_CBC_SHA` as the only CipherSuite in the tls.Config and use that transport with a client used to call the server which uses acme. Acme will then on-the-fly produce a RSA certificate (b00m.in+rsa).

```
tr := &http.Transport{ 
    TLSClientConfig: &tls.Config{
        CipherSuites: []uint16{tls.TLS_RSA_WITH_AES_256_CBC_SHA}
    }}
```
