---
title:  "SSL Problems with IE and XP"
categories: 
  - Windows
tags:
  - it
  - ssl
  - security
  - iis7
  - fix
---

Recently at work we had migrated our web server to a new virtual server, and when we were doing that we renewed our SSL certificate as it was about to expire. After getting all of the websites moved over and IIS7 configured correctly, I tested our secure site on my machine and a co-workers machine. Both machines were running Windows 7, and we made sure to check the site in Chrome, Firefox, and Internet Explorer. Since us IT people like to work at night to reduce impact on most of the general public, we assumed we were good to go. The next morning, we started to get calls about the secure site not working. Sure enough after going to see them it was easy to deduce that our secure site was not being rendered in Internet Explorer 6, 7 or 8 on Windows XP machines.

After looking into the error logs on the web server, I noticed that we were generating about 4,000 Schannel errors a day. The Schannel event IDs were 36888 and 36874. At this point I was trying anything and everything I could find on the internet, but nobody seemed to have this exact problem, so what I found was really limited. Just going off the errors I was receiving it appeared as though I did not have my cipher suites installed correctly, and upon looking in the registry, all that appeared was SSL 2.0. I tried adding the appropriate registry keys for TLS 1.0 and SSL 3.0, but that did not solve the problem. I tried enabling SSL 2.0, even though it was not a good practice just to see if IE would render anything. This did not fix it either. I played around with the settings on IE, enabling/disabling SSL 2.0, SSL 3.0, TLS 1.0, HTTPS 1.1 through Proxy, etc. Nothing was solving the problem.

The next thing that we tried was installing the intermediary certificates in the certificate store, and our SSL certificate was showing the correct path using those certificates, but this did not solve the problem either.

It turns out that when one of my coworkers installed the SSL certificate on our web server, he did some sort of base64 encoding to reduce the 4096 bit certificate to some smaller size. We decided to request a new certificate from the certificate authority with a length of 2048 bits. After we got the response, and installed the new certificate everything worked beautifully.
