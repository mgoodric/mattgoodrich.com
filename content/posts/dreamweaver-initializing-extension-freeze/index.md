+++
date = '2009-06-30T12:00:00-07:00'
draft = false
title = 'Fixing Adobe Dreamweaver Freeze on Domain Machine'
aliases = ['/software/dreamweaver-initializing-extension-freeze/']
summary = "I was experiencing issues with Adobe Dreamweaver freezing when opening, specifically getting stuck at the \"Initializing Extensions\" step. To resolve this issue, I renamed the Configuration folder in the Adobe Dreamweaver directory to force a rebuild of the configuration files."
genres = ['Software', 'Help desk']
tags = [ 'dreamweaver', 'adobe', 'freeze', 'configuration', 'issue']
[params]
  author = 'Matt Goodrich'
+++

I was having a problem with one of the machines in my domain freezing when opening Adobe Dreamweaver. It seemed to freeze when it said "Initializing Extensions".

To fix this I navigated to `C:\Documents and Settings\[current user]\Application Data\Adobe\Dreamweaver [9.0]\`.

I then located the "Configuration" folder and renamed it to something such as "Configuration2".

This causes the folder to be re-built in a non-corrupt manner.
