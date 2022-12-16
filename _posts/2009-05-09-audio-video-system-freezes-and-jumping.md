---
title:  "Audio/Video System Freezes and Jumping"
categories: 
  - Windows
tags:
  - windows
  - fix
  - freezing-audio
  - freezing-video
---

I have had a problem with my laptop a few times now where when I watch a video or try to listen to audio, the system will not play the media very smoothly.  After much research I found this is quite common in laptop disk drives as well as samsung disk drives.  The solution is quite simple.

The first thing to do is to Open up the device manager.  This can be done by right clicking "My Computer" then going to "Properties".  In Windows Vista there will be a link in the left column that says "Device Manager".  In XP you will click the "Hardware" tab, then "Device Manager". 

![image-center](/assets/images/avjump1.jpg){: .align-center}
<img alt="" class="postphoto" src="/files/postfiles/avjump1.jpg" />

After you have the Device Manager open expand the "IDE ATA/ATAPI controllers" section.

![image-center](/assets/images/avjump2.jpg){: .align-center}

In Vista your IDE Channel's will likely just shows as "IDE Channel", in XP it will likely show up as "Primary IDE Controller". Right click (usually the top option) the Primary IDE Controller and select "Uninstall".

![image-center](/assets/images/avjump3.jpg){: .align-center}

Now simply restart the machine and everything should be back to normal