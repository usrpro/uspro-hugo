---
title: "Mailu Persistent Storage"
date: 2019-09-13T16:24:25+03:00
draft: false
---
Permanent storage is a necessity in a mail server distribution like Mailu.
However, it increases difficulty in multi-host scaling. More users would like to deploy
Mailu on platforms like Kubernetes and Docker Swarm.

Previous attempts (by the author) to run Mailu on Docker Swarm concluded in many file locking issues, using the current file storage structure.

## Scope of this document
Since the last "attempt" many improvements are done to Mailu with regards to replicated
deployment. However, careful design decisions with regards to file storage still have to
be made and implemented. Such changes are not allowed to break existing Mailu
installations based on Docker Compose.

This document attempts to sum up improvements for replicated and stable deployment of
Mailu. The primary interest of the author is Docker Swarm, but it will definitely be of
the aid for Kubernetes deployments. With the aid of Kubernetes users, we can create a
unified solution for replicated deployments.

This document is divided per service (container).
For each service it attempts to describe:

1. The current storage layout or permanent files and the level of their importance;
2. Does its storage need to be shared with multiple instances or multiple services?;
3. Alternatives for omitting permanent storage or decentralizing storage;

Services that would be able to run without permanent storage will be able to work freely
in a "stateless" design and roam multi-hosts environment freely.

Services that require storage and don't require it to be shared will need to be bound to
hosts with local storage capabilities. They be can easily be replicated to achieve high
availability. There might be remaining garbage on hosts when containers are moved to
another host. Mailu should be able to continue to work if data from this category is lost / needs regeneration.

Finally, services that need to share storage between instances or other services are
restricted. Using networked filesystems tends to lead to file locking issues or
corruption. The alternative is to limit these services to a single host. This document
aims to **eliminate this category** as far as possible.

### Config file system
There are a number of services that need to store and share small amounts of persistent
data between other instances or other services. The requirements of such filesystems are
quite low when it comes to throughput and size. They need to be available to all
services, mostly at all times. The most straight-forward approach would be a distributed
filesystem like GlusterFS. And might later be improved to technologies like a KV store.
In this document we will assume a small distributed filesystem, which we will call **config store** for simplicity.

## General overview
In the default Docker Compose setup, all container mounts are located in the
`/mailu` directory structure. This location is currently managed by the `$ROOT` 
environment variable and evaluated once in `docker-compose.yml`.
Alternatively, in case of the setup utility, directly rendered into `docker-compose.yml`.
In distributed Mailu installations, the actual locations of volume mounts will actually 
depend on the requirements of each service. This is already taken care of in the
Kubernetes deployment files, but still in its infant stage for Docker Swarm.

````
$ sudo tree -d /mailu
/mailu
├── certs
├── data
├── dav
├── dkim
├── filter
├── mail
│   ├── admin@test.mailu.io
│   │   ├── cur
│   │   ├── new
│   │   ├── sieve
│   │   │   └── tmp
│   │   └── tmp
│   └── user@test.mailu.io
│       ├── cur
│       ├── new
│       ├── sieve
│       │   └── tmp
│       └── tmp
├── overrides
│   ├── nginx
│   └── rspamd
├── redis
└── webmail
    └── gpg
````

## Core/admin

**Tasks:**
- Web UI for managing domains, users, aliases and other database inputs and updates.
- Database abstraction API for authentication, mail routing and sieve.

### Current storage situation
There are two defined volumes: `/mailu/data` and `/mailu/dkim`.

1. `/mailu/data/instance`: a file containing a UUID for the statistics sender. Only accessed by this service.
2. `/mailu/data/main.db`: a SQlite file. Only accessed by this service and restricted parallel access. However, admin supports connecting to a database server like PostgreSQL or MySQL.
3. `/mailu/dkim`: Contains DKIM signing keys and is shared with RSpamd

In its default configuration, `admin` cannot be scaled due to the sqlite database.

### Improvement actions

| No  | Directory / file       | Improvement                 | Implementation        |
| --- | ---------------------- | --------------------------- | --------------------- |
| 1   | `/mailu/data/instance` | Config store                | Documentation / setup |
| 2   | `/mailu/data/main.db`  | Use only external DB server | Documentation / setup |
| 3   | `/mailu/dkim`          | Config store                | Documentation / setup |


### Conclusions
Fully scalable when configured correctly.

## Core/dovecot

**Tasks**
- IMAP server connectivity.
- Store incoming (LMTP) mail on filesystem.
- Sieve and manage-sieve.

### Current storage situation
1. `/mailu/overrides`: User specific config overrides. The current mountpoint overlaps with postfix, nginx, rspamd. Needs to be shared with all instances of this service.
2. `/mailu/mail`: User mailboxes and index files. Needs to be accessible from any invocation of Dovecot. There can only be a single instance accessing mail at the same time. Can lead to file locking issues if on a Networked filesystem as-is.
3. `/data`: defined as a `VOLUME` in Dockerfile, seems obsolete.

It can be concluded that Dovecot in its current situation can't be scaled up.
It should be bound to a single host, using a local filesystem. In case the host goes down,
IMAP service will be interrupted. However, mail should still be queued properly in SMTP
and delivered after an outage.

### Improvement actions

| No  | Directory / file       | Improvement                 | Implementation        |
| --- | ---------------------- | --------------------------- | --------------------- |
| 1   | `/mailu/overrides`     | Independent mount point     | `docker-compose.yml`  |
| 2   | `/mailu/overrides`     | Config store                | Documentation / setup |
| 3   | `/mailu/mail`          | Seprate Indexes             | Dovecot config        |
| 3   | `/mailu/mail`          | D-Sync or Director          | Additional services   |
| 4   | `/data`                | Delete                      | Dockerfile            |

#### D-Sync
[D-sync](https://wiki.dovecot.org/Replication) could improve H/A cases.
It allows two instances of Dovecot to run in a master to master synchronization on
their local data sets. This would greatly improve availability, but increases complexity.
Those individual dovecot instances would still need to be bound to their nodes.

#### Clustered / networked filesystem
According the Dovecot [homepage](https://www.dovecot.org/#c13), clustered filesystems are supported for multi-instance access.
File locking issues may appear on [NFS](https://wiki2.dovecot.org/NFS).
As the NFS article proposes, simultaneous access can be achieved by keeping the indexes separated from the mail files,
eg on a local file system. In the case of Mailu they might just as well reside in the volatile filesystem of the container.
Dovecot also suggests the use of a [Director](https://wiki2.dovecot.org/Director) dovecot proxy,
to keep user connections mapped to a particular instance in order to prevent constant regeneration of index files.

### Conclusions
In the current situation of Mailu, Dovecot cannot easily be scaled up. The less intrusive step,
portable between all deployment platforms, would be to store indexes separately in volatile container filesystem.

D-Sync and/or Director would need custom and complicated configuration which might not fall in the scope of Mailu.

## Core/nginx

**Tasks**
- HTTPS proxy for admin and webmail
- IMAP and SMTP authenticated proxy
- TLS termination for IMAP, SMTP and HTTP

### Current storage situation
1. `/mailu/overrides/nginx`: User specific config overrides. Needs to be shared will all instances of this service. 
2. `/mailu/certs`: TLS certificates, needs to be shared will all instances of this service. When `TLS_FLAVOR=letsencrypt` the container generates and writes the certificates here. This might be problematic in replicated deployments (race condition). Other TLS flavors require the user to put their certificates here manually, or using other tools.

### Improvement actions

| No  | Directory / file         | Improvement                     | Implementation        |
| --- | ------------------------ | ------------------------------- | --------------------- |
| 1   | `/mailu/overrides/nginx` | Config store                    | Documentation / setup |
| 2   | `/mailu/certs`           | No letsencrypt on Swarm and K8s | Documentation / setup |
| 3   | `/mailu/certs`           | Config store                    | Documentation / setup |

### Conclusions
Fully scalable when configured correctly.

## Core/postfix

**Tasks**
- Forwarding SMTP for trusted connections, authenticated through front
- Deliver incoming SMTP mail through LMTP to IMAP
- Interface with RspamD for milter/av.
- Maintain the mail queue until downstream delivery is successful.

### Current storage situation
1. `/mailu/overrides`: User specific config overrides. The current mountpoint overlaps with dovecot, nginx, rspamd. Needs to be shared with all instances of this service.
2. `/data`: defined as a `VOLUME` in Dockerfile, seems obsolete.
3. `/queue`: Only defined in `main.cf` and not as a `VOLUME`. Messages in the queue will be lost when the container is removed from a system. (Potential loss of mail)

### Improvement actions

| No  | Directory / file       | Improvement                 | Implementation        |
| --- | ---------------------- | --------------------------- | --------------------- |
| 1   | `/mailu/overrides`     | Independent mount point     | `docker-compose.yml`  |
| 2   | `/mailu/overrides`     | Config store                | Documentation / setup |
| 3   | `/data`                | Delete                      | Dockerfile            |
| 4   | `/queue`               | Create local volume         | Dockerfile            |

### Conclusions
After properly exposing the mail queue:
Maximum one instance per node, with a persistent local volume.
In case of a node failure / restart the postfix container on that node should always
be started again in order to empty the mail queue.

On docker swarm, a global placement with label specific constraints will achieve the required node attachment. A stack file could contain something like:

````
  deploy:
    mode: global
    placement:
      constraints:
        - node.labels.mailu.storage = smtp
````

Postfix would be able to scale up to any amount.
Scaling down has the risk of not emptying the queue properly.

## Optional/clamav

**Tasks**
- Virus scanner. Gets scan requests delegated from Rspamd.
- Automated updates of virus definitions

### Current storage configuration
1. `/mailu/filter`: Storage of virus definitions. This mount point is shared with Rspamd. This volume should **not** be shared between instances of this service, as it might lead to race conditions on freshclam. Definitions use ~350MB.
2. `VOLUME ["/data"]`: Container internal mount point. Forces a persistent storage for the container. If the administrator would choose not prove a mount point in `docker-compose.yml`, it would still create a volume under `/var/lib/docker`. This can lead to duplicated data when migrating containers between nodes.

### Improvement actions

1. Make `DatabaseMirror` in `freshclam.conf` configurable for local mirrors.

| No  | Directory / file       | Improvement                 | Implementation        |
| --- | ---------------------- | --------------------------- | --------------------- |
| 2   | `/mailu/filter`        | Independent mount point     | `docker-compose.yml`  |
| 3   | `VOLUME ["/data"]`     | Drop volume*                | Dockerfile            |

*) Dropping the volume would still allow admins to mount the `/data` path from
`docker-compose.yml` to have persistance.

### Conclusions
ClamAV is capable of free roaming and replication, if the sys admin would choose to
use named volumes. However, this might cause a lot of remote traffic for pulling in virus
definitions. Therefore it is advised that large organizations use a local
[Freshclam mirror](https://www.clamav.net/documents/private-local-mirrors).

## Remaining Optional services
The following services will not be included in this document (for now):

- Optional/radicale: Author has no practical experience with WebDAV installations;
- Optional/postgresql: deprecated and will be removed in the future;
- Optional/traefik-certdumper: select usage, no practical experience for author.

## Services/Fetchmail

**Tasks**
- Connect to a remote IMAP server and retransmit mails to local SMTP server

### Current storage configuration
No volumes are defined, however:
According [fetchmail documentation](www.fetchmail.info/fetchmail-man.html#12),
an `.idfile` is is used to keep track of previously downloaded messages.


| No  | Directory / file       | Improvement                  | Implementation        |
| --- | ---------------------- | ---------------------------- | --------------------- |
| 1   | `.idfile`              | Create persistent volume     | Dockerfile            |
| 2   | `.idfile`              | Provide mount point          | `docker-compose.yml`  |
| 3   | `.idfile`              | Config store                 | Documentation / setup |

### Conclusions
It is probably best not to replicate this service:
- Without `.idfile` persistence there will be lots of duplicated forwarding;
- With `.idfile` on the centralized "config store" poll events can become racy and results in some duplicate e-mail
- Failure and restart of this container does not cause a service interruption.

## Services/Rspamd

**Tasks**
- Filter HAM and SPAM messages
- Statistic and user action based learning
- Delegation of virus scanning to ClamAV
- DKIM signing of outgoing mail

### Current storage configuration
1. `/mailu/filter`: Storage of Bayes and Fuzzy learning **SQLite** databases and caches. This mount point is shared with ClamAV;
2. `/mailu/dkim`: Contains DKIM signing keys and is shared with Admin;
3. `/mailu/overrides/rspamd`: User specific config overrides;

### Improvement actions

| No  | Directory / file       | Improvement                 | Implementation        |
| --- | ---------------------- | --------------------------- | --------------------- |
| 1   | `/mailu/filter`        | Independent mount point     | `docker-compose.yml`  |
| 2   | `/mailu/dkim`          | Config store                | Documentation / setup |

### Conclusions

Rspamd can achieve [replication](https://rspamd.com/doc/tutorials/redis_replication.html) and high availability only when the Bayes and fuzzy
learning is stored in Redis and Redis uses a master/slave configuration. Following the documentation, there would be 3 redis instances per Rspamd.
It should be investigated if this setup can be simplified. It might however be concluded that such setup is not wished for in Mailu due to high
complexity. Hence, for now a indepenedent mount point is suggested.

Author is considering a separate docker-compose project for a Rspamd cluster that allows for integration with Mailu in enterprise set-ups.

## Webmails/Rainloop

**Tasks**
- Webmail user interface
- Stores client side contacts and preferences

### Current storage configuration
1. `/mailu/webmail`: Stores global and user configuration files. Holds a cache and `AddressBook.sqlite`. Shared witt Roundcube if multiple Webmails are used.

### Improvement actions

| No  | Directory / file       | Improvement                 | Implementation        |
| --- | ---------------------- | --------------------------- | --------------------- |
| 1   | `/mailu/webmail`       | Independent mount point     | `docker-compose.yml`  |
| 2   | `AddressBook.sqlite`   | Add config for external DB  | `application.ini`     |
| 3   | `/data/_data_/_default_/storage` | Only mount this directory in config store | `docker-compose.yml` / Dockerfile |

### Conclusions

If it is possible to add an option for an external SQL database, this service can be scalable.
Alternatively, integration with an external cardDAV server could be a solution. Taking that in account,
`/data/_data_/_default_/storage` should be the only part of the container directory structure that would beed to be mounted.

Application config files are generated at start and are stored in `/data/_data_/_default_/{domains,configs}`
and are accessible through the mount point. Admins modifying this files will find that they will get overwritten at next container start.
Therefore they should be written inside the container only. This would be in line with other services in the Mialu project.

Remaining data in the `/data/_data_/_default_` structure are caches.
They also belong inside the container. In multi-host deployments performance would suffer
from caches on a shared network filesystem with potential race conditions.

## Webmails/Roundcube

**Tasks**
- Webmail user interface
- Stores client side contacts and preferences 

### Current storage configuration
1. `/mailu/webmail`: Holds user gpg keys and `rouncube.db` for user preferences.

### Improvement actions

| No  | Directory / file       | Improvement                 | Implementation        |
| --- | ---------------------- | --------------------------- | --------------------- |
| 1   | `/mailu/webmail/gpg`   | Config store                | Documentation / setup |
| 2   | `rouncube.db`          | Add config for external DB  | `rouncube.db`         |

### Conclusions

It seems to be pretty straightforward to configure an external DB. Unlike Rainloop, there is no complexity in the mounted structure.
Therefore Roundube seems to scale easier than Rainloop.