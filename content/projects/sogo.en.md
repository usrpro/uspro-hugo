---
title: "Sogo"
date: 2019-09-19T11:29:00+03:00
draft: true
gh_issue: 199
---
Introduction
<!--more-->

## Current situation

Basic CalDAV and CartDAV superset protocols are supported by Radicale, which provides functionality to any third party webmail client that would support these protocols, but ships only as a server solution.


## Added functionality

https://sogo.nu/

SOGO would be given as an option to replace Radicale.

SOGO is a full, standard compliant, server and client solution that supports CalDAV, CardDAV, GroupDAV and synchronization.

- It works with existing IMAP, SMTP, LDAP and database servers.

- It provides authentication either by LDAP or SQL RDBMS.

Among its many features it stands out because of its support for:

- Two way synchronization achieved with Microsoft ActiveSync capable mobile devices or Microsoft Outlook.
    - sync contacts, events, tasks, e-mails.

- Comes with a modern webmail client interface.

- Provides support for Mozilla Thunderbird/Lightning clients.

- Compatible with Apple IOS Calendar application / Mac AddressBook application.

- S/MIME support, provides the opportunity to send encrypted e-mails.

#### Limitations and vulnerabilities:

- Sogo requires SQL rmdbs or LDAP access in order to authenticate users and store its admin privileged accounts.

- It requires access to the IMAP server in order to get inbox data either to its webmail or to serve it to other third e-mail clients e-mail clients.

- It also requires access to the SMTP server in order enable users to send e-mails.

## Scope

[Usrpro](/about/company/) offers to implement this feature.  This project will follow our general [road map](/about/projects-roadmap). The roadmap explains thoroughly which steps we will undertake to implement this feature and its crowd-funding. Until the "alpha testing" phase we promise to deliver:

- Updated configuration files providing SOGo or Radicale as an option.

- Integration of dockerized SOGo into the existing Mailu project architecture. 

### Licensing

Development will be done inside a public repository inside the usrpro organization of Github. All contributions will carry the MIT license, just like the Mailu upstream repository. Note that the license excludes the possibility of GPL-like licensed libraries and the design will depend on this restriction. During the development of this feature we commit to some additional guarantees outside the MIT license's warranty disclaimer. Please refer to our [Copyright and Licensing](/about/copyright-and-licensing/) page for more information.

## Costs

Usrpro believes it can benefit from this added functionality. We are looking for a partial funding of the development effort, so that the investment burden can be shared among other interested parties. As such we are able to offer works on the project as low as 15 euro per hour. After the design phase is concluded, we are able to do a final man-hour budget. The final budget will be our binding offer for implementing our scope. This means that the implementation costs can't rise once we start crowdfunding and we assume responsibility for delivering the project within budget.

## Project overview

| Phase          | Status      | Man hours | Calculation |
| -------------- | ----------- | --------- | ----------- |
| Initialization | In progress | -         | -           |
| Design         | Pending     | 16        | Preliminary |
| Crowdfunding   | Pending     | -         | -           |
| Implementation | Pending     | 40        | Preliminary |
| Alpha testing  | Pending     | 8         | Preliminary |
| Merge          | Pending     | 4         | Preliminary |
| Beta testing   | Pending     | 8         | Preliminary |
| **Project total** |          | **76**    | Preliminary |
