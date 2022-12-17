---
title:  "No Shut Down on Start Menu"
categories: 
  - Windows
tags:
  - windows
  - fix
  - logoff
  - start-menu
---

Here are the instructions for removing the shut down option from the start menu in Windows XP (and possibly other versions of windows as well).

Click Start - > Run.

 
![image-center](/assets/images/runcmd.jpg){: .align-center}

Type `regedit` and press "OK".

Navigate to `HKEY_CURRENT_USER\Software\ Microsoft\Windows\CurrentVersion\Policies\Explorer`.

![image-center](/assets/images/regedit.jpg){: .align-center}

Right-click on the NoClose entry, select Modify and type `1` in the Value data box.

If the key entry isn't there, add it by right-clicking in the Contents pane and selecting New/String Value.

Now give it a name and enter a value of `1`.

Exit RegEdit and reboot.

The shut down option should now be removed from the Start Menu.

To restore it, just change the value to `0`. You can also just delete the entire entry, press Ctrl+Alt+Delete, highlight Explorer and click on the End Task button. Cancel any dialogs that open, and the Shut Down option should work again.
