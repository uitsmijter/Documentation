---
title: 'Motivation'
weight: 3
---

# Motivation

Since the mid-nineties, we from aus der Technik have been dealing with the authentication and authorization of users.
The conception as well as the implementation of access systems is an elementary part of our work on clients
applications.
For new implementations, the first choice is between the numerous existing open source or proprietary authentication
systems, or the decision for or against a custom implemented solution.
Not only the numerous diverse requirements count on a decision-making process, but also legal questions about user
data management have to be considered individually.

When creating new applications in an agile project environment, the years of experience of migrating
legacy projects come into play: a too rigid system and a fixed structural formulation of user entities inhibits the
later paste of the process of building features. _That is not good_.
On the other hand, too complex authorization systems often stand in the way of a smart implementation, as numerous
dependencies directly affect the business applications to be created. As a result, more time is spent on bending the
user structure to fit the project requirements than on creating the optimal design for the use case. _That is not
good_.

Cloud providers of authorization solutions that bring the user data under their responsibility give the projects a
vendor lock-in that is almost impossible to leave with reasonably calculated means. OAuth as a standard was developed
as an open protocol that allows standardized, secure API authorization for desktop, web and mobile applications.
The current products in the SaaS market are funded precisely by hard lock-in through hosting their user entities,
so they can no longer be described as truly open. _That is not good_. Your data should be yours. Always. Anytime.

You should also be able to change the authorization system at any time without having to rewrite all your applications.
But to be honest, this is exactly the problem you face with the authorization products at the moment. Since the
authorization systems always require the persistence of the users (or specific delegations to other difficult to
influence providers of user data persistence) in their own data structures, a migration of the data from one provider to
another always involves considerable effort. _That is not good_.

This major problem becomes much clearer if we look at the current project landscape of medium-sized businesses:
numerous legacy applications carry an enormous amount of intellectual knowledge about the company. Applications that
have grown for years are the backbone of enterprise digitization. Without a doubt, these companies must face the
modernization of these applications. Decomposition into services to carry out partial modernizations, outsourcing of
partial applications to the cloud for scaling and the offering of machine-to-machine communication to offer partners an
integrated workflow is in full swing and will also accompany (for example us as a consultant for the modernization of
applications) the next decade.

In order to ensure that modernization can be planned step by step, it is first essential that authorization and
authentication are detached from the legacy systems and placed upstream of them. Only then partial services can be
extracted and the existing application continues to be used.

However, if the user data is detached from these applications, a long dependency tree is created, since these
applications are usually hard-bound to fields in the user table. These dependencies have to be solved and rebuilt in
such a way that external authentication is possible, accepted by the existing applications and new services can take
over. Projects that do not involve a complete rewrite are difficult to implement and can rarely be completed in less
than 8 months _That is not good_.

To be honest, fewer companies know about all the business implementation in all their code and "migration" means often
times "rebuild and reverse engineering the requirements". It is hard to tell the amount of time it takes and if it would
be better to rewrite the most of it, rather to maintain a bunch of logic with insecure and cumbersome authentication
delegates.
The only way to achieve a modernisation is a B-team that sets up the "new" environment, while the "old" one must be
maintained until a big-bang switch can be made. But this contradicts all processes we should work on. We have to bring
business value every sprint.

Admittedly, we in the industry have celebrated ourselves in the past when we - or colleagues - have managed to perform
migrations from monolithic applications to the cloud in half to three quarters of a year. The smart solutions were
often described, shown at conferences and architects of these migrations are highly sought after employees ([by the way:
we also do](https://www.ausdertechnik.de/jobs)).

That alone is not good. We should not be happy about it, nor proud. 80 different "Certified OpenID Provider Servers"
are currently listed on [🔗 the openid website](https://openid.net/developers/certified/). Most of them are perfect, but
all of them have the problem of trying to tell you what to do with your user data and how to handle them. All these
products do not assume that user databases already exist. And that they are existing in that fashion for a good reason.
They don't nestle into the existing infrastructure and thus all cause a lot of trouble within the projects. However,
the wealth of possibilities offers something for everyone. So why are we creating another Authorization Server in 2022?

Based on the facts described, we accompanied projects that were very long, complex and expensive in their migration
strategy. We saw projects that after a 2.5 year migration of user data had to go directly into the next migration
because the selected SaaS provider was no longer continuing its services. _That is not good_.
We have seen customer projects that share sessions between applications due to the fact of a migration pressure.
_That is not good_. Projects that were offline for several days due to user migrations. _That is not good_. We have
seen code from large companies that we would rather not have seen. _That is not good_. And all because we as developers
were happy with difficult migrations of ~8 months. We are not anymore, because they are not good!

Uitsmijter was developed to set new standards: Authorization and authentication should be fun and an authorization
server should support your daily work, instead of dictating how your business should look like. Migrating from a
monolith legacy application to accept a single-sign-on token should take hours, not months. An authorization server
should support you by designing new complex systems, not telling you how to do it. An authorization server has to be
very fast and super reliable.

Uitsmijter is a versatile authorization server that opens up possibilities to make migrations work well. The answer to
how to better support one of these has been given in every code decision - and with growing implementations we are
learning and improving Uitsmijter. So much so that Uitsmijter is the ideal starting point for a new project. User
authentication that is based on your requirements.
