---
title: "RESTful API"
date: 2019-09-19T11:29:00+03:00
draft: true
gh_issue: 445
---
A RESTful API would allow third party applications to interact with Mailu in a defined way. Currently the Admin service exposes an API for all database interaction, like authentication, mailbox checking, sieve management and more. The API is however not engineered for external usage yet.

## Current situation

Domains, users, aliases and their properties are stored in a SQL database. The Admin service is a flask framework, with an integrated ORM. It has a web interface where users, managers and administrators can manage user settings, passwords, adding and removing accounts, setting aliases, auto reply and forward and many other features. The Admin service exposes a minimal API, served from the `/internal` path. The interactions on this path are used by Podop for user authentication, mailbox routing, aliases and sieve. Database modifications are done through the Admin web interface, which is served by the same server as the API.

## Added functionality

This feature will allow all current Admin interactions to take place through an API. This allows for easy integration in automated user registration systems. This project will also form a solid base for the support of different user authentication back-ends like OAuth / openID and LDAP. The API will be designed with performance and maintainability in mind.

Furthermore, this allows us to separate the Admin web interface from the actual API. The API will be designed for performance and maintainability. While the views for the Admin can be developed separately, allowing for contributors with front-end only knowledge.

## Scope

This project will follow our general [road map](/about/projects-roadmap).

Usrpro, a division of Mohlmann Solutions SRL, Romania, offers to implement this feature. Each phase will have a estimated budget assigned and will be put into motion once sufficient funding is acquired. The following scope will be implemented and delivered until the Alpha testing phase:

- Implementation written in the chosen framework
- Unit tests for all endpoint handlers
- API documentation

### Licensing

Development will be done inside a public repository inside the usrpro organization of Github. All contributions will carry the MIT license, just like the Mailu upstream repository. Note that the license excludes the possibility of GPL-like licensed libraries.

### Warranty

After acceptance into the "Beta testing phase", usrpro will commit in solving any production critical bugs inside the submitted code. Usrpro will do so in a timely fashion within allowance of the usual review process of pull requests against Mailu. However, the limitation of warranty as stated in the MIT license remains in effect for this addition as part of Mailu:

> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Costs

Usrpro believes it can benefit from this added functionality. We are looking for a partial funding of the development effort, so that the investment burden can be shared among other interested parties. As such we are able to offer works on the project as low as 15 euro per hour. Depending on the outcome of the design phase, as actual budget can be appointed.