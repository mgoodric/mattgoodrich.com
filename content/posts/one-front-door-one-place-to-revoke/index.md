+++
date = '2026-06-16T00:01:00-07:00'
draft = false
title = 'One Front Door, One Place to Revoke'
aliases = []
description = "Single sign-on is the first IAM investment worth making, and the math is plain: every app times every employee is an access relationship someone tracks by hand. Consolidating logins behind one identity provider turns offboarding into a single switch. The catch is the long tail of apps that will not federate, and what to do with them."
categories = ['Security', 'Engineering']
tags = ['Security', 'IAM', 'Identity', 'SSO', 'Single Sign-On', 'Access Management', 'IdP', 'CISO']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

I almost did not write this one. In my head, SSO is settled: table stakes, the thing every company past a certain size obviously has, and a whole post arguing for it felt redundant. Two things changed my mind. A lot of companies are not as consolidated as they think they are. And the ones that are usually bought SSO for the convenience and stopped there, short of the part that actually matters.

Single sign-on gets sold as a convenience: one login instead of forty, fewer password resets, happier employees. That is a real benefit and it is the least important one. The reason SSO is the first IAM investment worth making is that it gives you one place to cut someone off. Before SSO, a departure means hunting through every app one at a time, hoping you got them all. After it, you disable one account and the doors close together.

This is the rung the [right-sized IAM ladder](/posts/iam-for-the-company-you-have/) puts right after the basics, and it is the one most companies reach a year or two later than they should. The trigger is always the same: onboarding and offboarding start to hurt, and nobody can answer who still has access to what.

## The Math That Justifies an IdP

You can tell when an IdP is worth standing up with one multiplication. Take the number of applications people log into and multiply by the number of employees. That product is the count of access relationships in your company, and every one of them is something that has to be created when someone joins and removed when they leave.

At fifteen people across eight apps, that is a hundred and twenty relationships. You can track that in a spreadsheet, and an identity provider would cost more than it saves. At fifty people across thirty apps, it is fifteen hundred, and the spreadsheet is already lying to you. Nobody is tracking fifteen hundred relationships by hand, which means some of them are wrong right now: access that should have been removed months ago and was not, because a manual process at that scale always leaks.

An identity provider collapses the multiplication. Instead of managing apps times employees, you manage employees, and the apps inherit access from one place. Stand up Okta, Microsoft Entra ID, or Google Workspace as the directory, connect your applications to it, and the per-app account stops being the unit of work. The account in the IdP is. If you would rather run the directory yourself, [Keycloak](https://www.keycloak.org/), [Authentik](https://goauthentik.io/), and [Zitadel](https://zitadel.com/) are open-source identity providers that speak the same SAML, OIDC, and SCIM.

## One Place to Grant, One Place to Revoke

Centralization shows up at both ends of the lifecycle.

On the way in, a new hire gets the apps their role calls for because the IdP grants them, not because someone remembered to create forty separate accounts. On the way out, disabling the IdP account pulls the rug from every connected app at once. The departure that used to be a checklist of twelve manual revocations, with a real chance of missing one, becomes a single action with a single audit record.

Two kinds of work happen here, and it is worth knowing which protocol does which. [**SAML**](https://docs.oasis-open.org/security/saml/v2.0/saml-core-2.0-os.pdf) and [**OIDC**](https://openid.net/specs/openid-connect-core-1_0.html) handle authentication: when a user opens an app, the app bounces them to the IdP to prove who they are, and the IdP vouches for them. [**SCIM**](https://datatracker.ietf.org/doc/html/rfc7644) handles provisioning: it pushes account creation, updates, and deactivation from the IdP into the app, so disabling someone centrally actually deletes or disables their account downstream rather than just blocking the login. SSO without SCIM still leaves orphaned accounts behind in each app; the login is blocked, but the account lingers. The full lifecycle story, provisioning and deprovisioning access as people join, change roles, and leave, is its own topic.

One more thing consolidates with the logins: the strength of the authentication. When every app sits behind the IdP, turning on phishing-resistant MFA once protects all of them, and a conditional access policy written once applies everywhere. That single point of control on the authentication side is a large part of why getting apps behind the IdP matters beyond offboarding.

## In Front of the IdP vs Behind It

Here is the distinction that decides how complete your SSO actually is. Every application is either **behind the IdP**, federated through SAML, OIDC, or SCIM so the identity provider controls access to it, or **in front of the IdP**, standing on its own with its own local accounts and its own password. The goal of an SSO program is to move as much as possible behind the line, because everything behind it is governed by the single account, and everything in front of it is back to the manual, per-app problem you were trying to escape.

Most apps can move behind it. The modern ones speak SAML or OIDC out of the box, and connecting them is an afternoon of configuration. The program is mostly a queue: inventory the apps, sort by how many people use them and how sensitive they are, and work down the list.

The trouble is the apps that cannot or will not cross the line.

## The Long Tail Is the Real Work

Three kinds of application resist federation, and together they are where an SSO rollout actually spends its effort.

The first is the **app that charges for it**. A surprising number of vendors gate SAML behind their most expensive tier, so turning on SSO for a tool you already pay for means a large upgrade bill for a security feature that should be table stakes. This is common enough to have a name and a public shaming site, [the SSO tax](https://sso.tax/). Sometimes the upgrade is worth it for a sensitive system and sometimes it is not, and that is a real budget decision, not a technicality.

The second is the **app that cannot federate at all**: the old on-prem tool, the niche vendor portal with no SAML support, the homegrown internal system nobody has touched in years. These cannot move behind the IdP without engineering work that may never be worth it.

This is the corner of the post that brings back memories. Early in my career I worked on single sign-on for an AS/400, and teaching a green-screen system with its own idea of who its users were to accept a central identity was its own particular kind of project. Every company has a machine like that, the one nothing new can quite talk to. The logo on the box changes; the problem does not.

The third is the **shared or service login** that is not tied to a person at all: the social media account, the registrar, the vendor portal with one set of credentials the team passes around. These do not fit the SSO model because there is no individual identity to federate.

For all three, the answer is the same shape: an enterprise password manager as the catch-all for what cannot go behind the IdP, with those credentials scoped, shared through the manager rather than through chat, and rotated when people leave. It is a weaker control than federation, and you should be honest that it is. The apps behind the IdP are governed; the apps in the password manager are merely contained. The job is to keep shrinking the second group, push vendors on SAML pricing at renewal, and make sure the most sensitive systems are never the ones stuck in front of the line.

## Let the Proxy Speak SAML, Let the App Read a Header

There is a middle path between full federation and the password manager, and it rescues a lot of the long tail. For any app whose deployment you control, you can put an authenticating reverse proxy in front of it. The proxy does the hard part, the full SAML or OIDC handshake with your IdP, and then passes the authenticated identity to the app in a simple HTTP header: `X-Auth-Request-Email`, `X-Forwarded-User`, whatever you configure. The app implements no standard at all. It reads a header.

![The Header-Injection Pattern: a User's Request Hits an Authenticating Reverse Proxy That Does the SAML or OIDC Handshake With the Identity Provider, Then Injects the Authenticated Identity Into a Header the App Simply Reads, While the App Stays Reachable Only Through the Proxy and Direct Access Is Blocked](diagram-proxy-header.png)

Reading a header is a few lines in any framework. Implementing SAML or OIDC correctly, with signature validation, metadata, session handling, and every edge case, is a real project no team should take on for an internal tool. The proxy implements it once, in front of everything, and every app behind it gets single sign-on for the price of trusting one header. [oauth2-proxy](https://oauth2-proxy.github.io/oauth2-proxy/) is the common open-source choice; [Authelia](https://www.authelia.com/) and [Pomerium](https://www.pomerium.com/) do the same job, and on Apache or nginx the pattern runs through [mod_auth_openidc](https://github.com/OpenIDC/mod_auth_openidc) or the `auth_request` directive. Point the proxy at your IdP, set the header, and the homegrown app from a moment ago is behind the line without a line of federation code in it.

The catch is the one that turns this into a vulnerability when it is done carelessly: the app must be reachable only through the proxy, and the proxy must strip any copy of the identity header that arrives from the client. If a user can reach the app directly, or smuggle in their own `X-Auth-Request-Email`, they can claim to be anyone, because the app trusts that header completely. The header is a statement only the proxy is trusted to make, so the network has to guarantee the proxy is the only one who can make it. Terminate all traffic at the proxy, isolate the app behind it, and overwrite those headers on the way through. Get that wrong and you have built an impersonation endpoint with a login page in front of it.

## The Crown Jewels Are the Test

The honest version of an SSO program is that you will never get every app behind the IdP, and chasing that completion is the wrong goal. There will always be a tail of low-use, low-sensitivity tools where the federation work or the SSO tax costs more than the risk of leaving them in the password manager. That is a defensible place to stop.

What is not defensible is leaving a crown-jewel system in front of the line. The test that matters is whether the systems whose compromise would hurt most, the cloud console, the code host, the financial systems, the customer data, are all behind the IdP, covered by the central account, the central MFA, and the single revocation. A high count of federated apps proves nothing if one of those is still standing on its own password. Get those across the line first, accept a long tail of minor tools in the password manager, and you have the value SSO is actually for.

| Where the app sits | What governs access | What offboarding looks like |
|---|---|---|
| Behind the IdP (SAML/OIDC/SCIM) | One central account, central MFA, central policy | Disable one account, access closes everywhere |
| In the password manager (the tail) | A shared, scoped, rotated credential | Rotate the credential, remove the share |
| In front of both (ungoverned) | A local password someone set up | You hunt, and you hope |

The third row is the one to drive to zero for anything that matters.

## The First Switch You Build

Before SSO, identity is a dozen scattered switches, and a departure means finding and flipping every one. After it, the important ones are a single switch, and the rest are contained somewhere you can at least see them. That is the whole pitch: not the convenience of one login, but the control of one revocation.

Stand up the identity provider, move your crown jewels behind it first, put phishing-resistant MFA behind that, and treat the long tail as a queue you work down rather than a finish line you cross. The day you can offboard someone with one action and trust it, you have bought the rung. Everything after it in the identity program assumes you are standing on it.
