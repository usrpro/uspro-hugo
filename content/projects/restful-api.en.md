---
title: "RESTful API"
date: 2019-09-19T11:29:00+03:00
draft: false
gh_issue: 445
---
A RESTful API would allow third party applications to interact with Mailu in a defined way. Currently the Admin service exposes an internal API for all database interaction, like authentication, mailbox checking, sieve management and more. The API is however not engineered for external usage yet.
<!--more-->

## Current situation

Domains, users, aliases and their properties are stored in a SQL database. The Admin service is a flask framework, with an integrated ORM. It has a web interface where users, managers and administrators can manage user settings, passwords, adding and removing accounts, setting aliases, auto reply and forward and many other features. The Admin service exposes a minimal API, served from the `/internal` path. The interactions on this path are used by Podop for user authentication, mailbox routing, aliases and sieve. Database modifications are done through the Admin web interface, which is served by the same server as the API.

## Added functionality

This feature will allow all current Admin interactions to take place through an API. This allows for easy integration in automated user registration systems. This project will also form a solid base for the support of different user authentication back-ends like OAuth / openID and LDAP. The API will be designed with performance and maintainability in mind.

Furthermore, this allows us to separate the Admin web interface from the actual API. The API will be designed for performance and maintainability. While the views for the Admin can be developed separately, allowing for contributors with front-end only knowledge.

## Scope

[Usrpro](/about/company/) offers to implement this feature.  This project will follow our general [road map](/about/projects-roadmap). The roadmap explains thourougly which steps we will undertake to implement this feature and its crowd-funding. Until the "alpha testing" phase we promise to deliver:

- Implementation written in the chosen framework;
- Unit tests for all endpoint handlers;
- API documentation;

From the alpha phase untill merge we will work on integration testing, bug-fixing and updates as per reviewers requests. THose phases heavily rely on community feedback. Once the code for this feature is merged, we consider our scope delivered.

The exact integration with the Admin web UI will need to be decided during the design phase.

### Licensing

Development will be done inside a public repository inside the usrpro organization of Github. All contributions will carry the MIT license, just like the Mailu upstream repository. Note that the license excludes the possibility of GPL-like licensed libraries and the design will depend on this restriction. During the devlopment of this feature we commit to some additional guarantees outside the MIT license's warranty disclaimer. Please refer to our [Copyright and Licensing](/about/copyright-and-licensing/) page for more information.

## Costs

Usrpro believes it can benefit from this added functionality. We are looking for a partial funding of the development effort, so that the investment burden can be shared among other interested parties. As such we are able to offer works on the project as low as 15 euro per hour. After the design phase is concluded, we are able to do a final man-hour budget. The final budget will be our binding offer for implementing our scope. This means that the implementation costs can't rise once we start crowdfunding and we assume responsibilty for delivering the project within budget.

## Project overview

| Phase          | Status      | Man hours | Calculation  |
| -------------- | ----------- | --------- | ------------ |
| Initialization | In progress | -         | -            |
| Design         | Pending     | 16        | Preleminairy |
| Crowdfunding   | Pending     | -         | -            |
| Implementation | Pending     | 40        | Preleminairy |
| Alpha testing  | Pending     | 8         | Preleminairy |
| Merge          | Pending     | 4         | Preleminairy |
| Beta testing   | Pending     | 8         | Preleminairy |
| **Project total** |          | **76**    | Preleminairy |