---
title:  "Dreamweaver Initializing Extension Freeze"
categories: 
  - Software
tags:
  - fix
  - dreamweaver
  - freeze
---

I was having a problem with one of the machines in my domain freezing when opening Adobe Dreamweaver. It seemed to freeze when it said "Initializing Extensions".

To fix this I navigated to `C:\Documents and Settings\[current user]\Application Data\Adobe\Dreamweaver [9.0]\`.

I then located the "Configuration" folder and renamed it to something such as "Configuration2".

This causes the folder to be re-built in a non-corrupt manner.
