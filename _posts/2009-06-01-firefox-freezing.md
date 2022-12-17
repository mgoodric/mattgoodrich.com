---
title:  "Firefox Freezing"
categories: 
  - Software
tags:
  - freezing
  - firefox
  - fix
---

This tip was given to me by a co-worker at Colorado State University where I work.

The problem was Firefox was starting very slowly, froze often, and often required the user to end the process.  

After a bit of Googling he landed upon this link:  <a href="http://kb.mozillazine.org/Locked_or_damaged_places.sqlite">http://kb.mozillazine.org/Locked_or_damaged_places.sqlite</a>

Turns out his places.sql file was over 200MB, after running this fix everything seemed back to normal.
