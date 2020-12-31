---
title: Deploy
linktitle: Deploy
description: Deploy B00M server to GCP/AWS/Azure.
date: 2019-05-30
publishdate: 2019-05-30
lastmod: 2019-05-30
categories: [hosting and deployment]
keywords: [aws,gcp,azure,hosting,deployment]
authors: [rcs]
menu:
  docs:
    parent: "hosting-and-deployment"
    weight: 2
weight: 2
sections_weight: 2
draft: false
aliases: []
toc: true
---

## Assumptions

* You have completed the [Quick Start][].
* You have an account with the service provider ([Google Cloud](https://cloud.google.com/), [AWS](https://aws.amazon.com), or [Azure](https://azure.microsoft.com)) that you want to deploy to.
* You have authenticated.
  * Google Cloud: [Install the CLI](https://cloud.google.com/sdk) and run [`gcloud auth login`](https://cloud.google.com/sdk/gcloud/reference/auth/login).
  * AWS: [Install the CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) and run [`aws configure`](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).
  * Azure: [Install the CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) and run [`az login`](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli).
  * NOTE: Each service supports alternatives for authentication, including using environment variables. See [here](https://gocloud.dev/howto/blob/#services) for more details.


[Quick Start]: /getting-started/quick-start/
[Google Cloud]: [https://cloud.google.com]
[AWS]: [https://aws.amazon.com]
[Azure]: [https://azure.microsoft.com]

