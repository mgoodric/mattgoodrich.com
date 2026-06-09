+++
date = '2026-06-18T12:00:00-07:00'
draft = false
title = 'Logging Out Is Harder Than Logging In'
aliases = []
description = "Single sign-on made logging in a solved problem. Logging out never did: disabling an account leaves live sessions running, and the single-logout standards meant to fix it are fragile or unevenly adopted. What works is a newer approach, near-real-time session-revocation signals, and here's why logout is the hard half and what actually ends a session now."
categories = ['Security', 'Engineering']
tags = ['Security', 'IAM', 'Identity', 'SSO', 'Single Logout', 'OIDC', 'Session Management', 'CAEP', 'CISO']
image = 'header.png'
[params]
  author = 'Matt Goodrich'
+++

Single sign-on solved logging in. One identity provider, one handshake, and every app trusts the result. Logging out never got the same treatment, and the reason is structural: there was never just one session to end.

When you log into an app through SSO, the identity provider proves who you are once, and then the app sets up its own session and stops asking. Killing your account at the IdP does nothing to that session, because the app was never checking back. This is why a disabled employee can keep working in a tool for days: the [account is revoked but the session is not](/posts/automate-the-leaver-before-the-joiner/), and the session is the thing actually serving the requests.

## There Is Never Just One Session

Count the sessions behind a single SSO login and there are at least two, usually more.

There is the **IdP session**, your authenticated session at the identity provider, the thing that lets you open a second app without logging in again. There is the **application session** at each service provider, created the moment the IdP vouches for you, living in that app's own cookie or token and governed by that app's own rules. Log into five apps through SSO and you have one IdP session and five app sessions: six independent timers, each set by a different team with different defaults.

Under those sit the token lifetimes. An OIDC access token might be good for an hour, while the refresh token behind it is good for weeks, quietly minting new access tokens the whole time. The app session, the access token, and the refresh token are three more clocks, and they do not run together.

Put numbers on it and the problem is plain. A common setup is an eight-hour sliding app session, a one-hour access token, a thirty-day refresh token, and an eight-hour IdP session. Disable the account at noon and the access token keeps working until one o'clock, the refresh token can mint fresh ones for a month, and the sliding app session renews for as long as the tab stays open. The single logout you wanted is four different expiries owned by three different systems, and none of them fired when you clicked disable.

![One SSO Login Creates Several Independent Sessions and Tokens, Each on Its Own Clock: an IdP Session, a Sliding App Session, a Short Access Token, and a Long Refresh Token; Disabling the Account Blocks the Next Login but Leaves the Access Token Valid Until It Expires, the Refresh Token Minting New Ones for Weeks, and the Sliding App Session Alive Until the Tab Closes](diagram-sessions.png)

The load-bearing word is independent. SSO is a one-time handshake, not a standing connection. Once the app has its session it has no reason to phone the IdP on every request, and for performance it deliberately does not. The decision that makes SSO fast is the same decision that makes logout hard. There is no single session to end, and no single place that knows about all of them.

## Fixed vs Sliding Sessions

Sessions also differ in how they expire, and that difference decides how long a stranded one lives.

A **fixed** or absolute session ends a set time after login whether you are active or not: eight hours, then back to the login screen. A **sliding** session, also called rolling, resets its timer on every bit of activity, so a user who keeps working never gets logged out. Most apps default to sliding, because logging active users out feels broken to them.

Sliding is where access quietly becomes immortal. As long as the session stays active enough, a background tab polling, a mobile app checking for messages, it renews itself indefinitely, and "active enough" is a low bar. A disabled account whose app session is sliding does not expire on a schedule. It expires when the person finally closes the tab, which can be never. The [OWASP session management guidance](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html) is to pair an idle timeout with a hard absolute timeout for exactly this reason, so a sliding session has a ceiling it cannot renew past. Most apps ship the convenient default and skip the absolute cap.

A tight session on one end does not bound the other. You can set a strict one-hour IdP session and feel covered, but if the app opened a long sliding session of its own at login, the IdP timeout never touches it. Exposure is set by the loosest session in the chain, not the tightest, because the sessions do not coordinate. Bounding the IdP session limits how long single sign-on stays convenient. It does nothing to the app session that is actually answering requests.

## Single Logout Was Supposed to Fix This

The standards bodies saw this coming and built single logout, the mechanism for ending all those sessions at once. It has a long and unhappy history.

SAML 2.0 has a Single Logout profile, and in practice it is fragile. The front-channel version walks the user's browser through a chain of logout redirects, and if any one participant is slow or unreachable, the chain breaks and some sessions stay open. Most deployments either never enable it or never trust it.

OIDC split the problem in two, and both halves are now finished specifications rather than the drafts they spent years as. [Front-Channel Logout](https://openid.net/specs/openid-connect-frontchannel-1_0.html) loads each app's logout URL in a hidden iframe; it was never robust, and the browser industry's move to block third-party cookies has largely finished it off. [Back-Channel Logout](https://openid.net/specs/openid-connect-backchannel-1_0-final.html) is the reliable one: the IdP sends a logout token straight to each app's server, no browser involved. It works, when the app implements a back-channel logout endpoint, and a great many apps simply do not. A standard reaching final status does not make the long tail of vendors support it.

## Revoke the Session With a Signal

The approach that actually fits the problem is newer, and it gives up on propagating a logout in favor of broadcasting a fact. The OpenID Foundation's [Shared Signals Framework](https://openid.net/specs/openid-sharedsignals-framework-1_0-final.html) and its [Continuous Access Evaluation Profile](https://openid.net/specs/openid-caep-1_0-final.html) reached final status together, and CAEP defines a `session-revoked` event for exactly this. The IdP, acting as a transmitter, pushes a signed event to each participating app, the receiver, that says this subject's session is revoked. The app drops the session in near-real-time, without waiting for a token to expire or a redirect to fire.

This is the model that closes the gap short token lifetimes cannot. Microsoft ships it as [Continuous Access Evaluation](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-continuous-access-evaluation), where a termination or a risky sign-in can end active sessions in about a minute rather than waiting out the token. Okta and Google are building Shared Signals support. The direction is clear: instead of chaining a logout through every app, broadcast the revocation as a fact and let each app act on it.

![Three Ways to End Sessions: Front-Channel Logout Loads Each App's Logout URL in a Browser Iframe and Is Broken by Third-Party Cookie Blocking; Back-Channel Logout Sends a Server-to-Server Logout Token but Only Reaches Apps That Implement It; Shared Signals and CAEP Have the IdP Push a session-revoked Event to Receiving Apps That Drop the Session in Near-Real-Time](diagram-logout-vs-signal.png)

## What You Can Actually Ship Today

Shared Signals is the right model, and it is not a switch you flip, because it only works where both ends implement it. Your IdP has to transmit and every app has to receive, and the app long tail that never adopted back-channel logout is the same long tail that will not have a Shared Signals receiver for years. For those apps you are back to waiting out the session.

So the deployable answer is layered, weakest to strongest. Set short absolute lifetimes on the sessions and tokens you control, accepting the extra re-authentication, because a short fixed session is the one mitigation that works without the app's cooperation. Revoke the refresh token at the IdP through [OAuth token revocation](https://www.rfc-editor.org/rfc/rfc7009) the moment the account is disabled, so it stops minting new access tokens even if nothing else fires. Turn on [back-channel logout](https://openid.net/specs/openid-connect-backchannel-1_0-final.html) for the apps that support it; the open-source identity providers implement it, [Keycloak](https://www.keycloak.org/), [Authentik](https://goauthentik.io/), and [Ory Hydra](https://www.ory.sh/hydra/), if you want to run the mechanism end to end. Adopt Shared Signals and CAEP between your IdP and the apps where a terminated session has to die in minutes, not hours; SGNL's [caep.dev](https://caep.dev/) is a free CAEP transmitter to test against, with an [open-source receiver library](https://github.com/SGNL-ai/caep.dev) to start from. And for everything still on a sliding session you cannot signal, the honest move is to know it is there and shorten it where you can, instead of assuming logout did something it did not.

## Logging In Is a Handshake; Logging Out Is a Distributed-Systems Problem

Logging in is a handshake: one exchange, one answer, and you are in. Logging out is several independent sessions, set by different teams with different timeouts, none of them watching the others, and no single place that can end them all at once. The standards that promised to close them in one click never quite delivered, and the model that works, pushing a revocation signal to every app, only helps where the app is listening.

The practical version is unglamorous. Know how many sessions a login actually creates, keep the ones you control short, signal the ones you can, and stop treating a disabled account as a closed session. The account is the door. The session is the person already inside.
