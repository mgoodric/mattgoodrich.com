+++
date = '2009-07-29T12:00:00-07:00'
draft = false
title = 'Fixing a PDF Export Issue with InDesign CS4 and Adobe Acrobat'
aliases = ['/software/acrobat-9-problem-2-pixel-white-line/']
description = "I helped my co-worker troubleshoot an issue where his exported PDFs from InDesign CS4 had a two-pixel white line on the right-hand side, which turned out to be an issue with Adobe Acrobat itself."
categories = ['Software', 'Help desk']
tags = ['indesign', 'acrobat', 'pdf', 'export', 'adobe', 'issue']
[params]
  author = 'Matt Goodrich'
+++

A co-worker of mine was having a problem when exporting a PDF from InDesign CS4.

Every time he would export, regardless of his settings (Acrobat 5 and up). he was getting a two pixel white line on the right hand side of his PDF.

When going all the way back to Acrobat 4 it went away, but the feature set in Acrobat 5 was needed.

It ended up being an issue with Acrobat itself.

In Acrobat 9, under Edit > Preferences > Page Display - Uncheck "Use 2D Graphics Acceleration."