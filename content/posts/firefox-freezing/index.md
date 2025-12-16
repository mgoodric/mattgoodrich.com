+++
date = '2009-06-01T12:00:00-07:00'
draft = false
title = 'Fixing Slow and Freezing Firefox with a Simple SQLite File Repair'
aliases = ['/software/firefox-freezing/']
description = "I was given a tip by a colleague that helped me resolve issues with slow and freezing Firefox on my computer. After applying the suggested fix, I ran into an issue with my places.sql file being over 200MB, but a repair tool resolved the problem and got everything running smoothly again."
categories = ['Software', 'Help desk']
tags = ['firefox', 'issue', 'freezing', 'slow']
[params]
  author = 'Matt Goodrich'
+++

This tip was given to me by a co-worker at Colorado State University where I work.

The problem was Firefox was starting very slowly, froze often, and often required the user to end the process.  

After a bit of Googling he landed upon this link:  [http://kb.mozillazine.org/Locked_or_damaged_places.sqlite](http://kb.mozillazine.org/Locked_or_damaged_places.sqlite)

Turns out his places.sql file was over 200MB, after running this fix everything seemed back to normal.