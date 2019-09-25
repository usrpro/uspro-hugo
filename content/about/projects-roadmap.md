---
title: "Projects Roadmap"
date: 2019-09-20T18:25:44+03:00
draft: true
weight: 1
---
All features that usrpro picks for implementation follow the same roadmap. We wish to prevent situations where persons invest into a feature which will not gain enough traction to take off. Therefore we prefer not to receive specific funding until the design of a feature is published. Effectively, this puts any project into negative budget, for which usrpro assumes the risk.

### Initialization

Before we get started, usrpro would like to acquire support from future investors. In this stage we will reach out to the community to poll the interest of crowdfunding this feature. No payments will be required yet. Once we receive enough support and investment promises, we will proceed to the design phase.

### Design phase

A design proposal will be written and posted as Pull Request against Mailu. A public discussion will take place, during which the design will be updated to meet the requirements.

### Crowdfunding phase

After the design is completed, we are able to do an accurate calculation of the required budget. We will reach out to the promised investors and the community to raise the required funds. Once a certain buffer is established, we will commence work in the implementation phase.

### Implementation phase

We (usrpro) will implement the required code to meet the requirements laid down in the design. Implementation will happen on a public fork of Mailu in the usrpro Github organization.

### Alpha testing phase

Once the design in implemented, a new branch will be created in the Mailu organization, based on the most current master, merged with the new feature. This branch will allow for public Alpha testing and review of the API feature. This phase allows for re-implementation of parts that are not performing as expected. This 

### Merge phase

After sufficient feedback in the testing phase, a Pull request will be opened against master. Here a final check is done by reviewers in order not to break anything in the current master. This phase is for compatibility fixes only.

### Beta testing phase

In the period between merge and the next Mailu version, beta testing of the new feature will take place by a larger crowd. This period is meant for Bug fixes and allows for optimizations.