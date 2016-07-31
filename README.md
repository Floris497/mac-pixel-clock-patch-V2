# mac-pixel-clock-patch-V2

Based on [my fork of the repository](https://github.com/floris497/mac-pixel-clock-patch) and [the original project which is hosted on google code](https://code.google.com/p/mac-pixel-clock-patch/wiki/Documentation)

## 10.11.6 now supported by script 

## Experimental for 10.12 16A201w. there seem to be many changes in 10.12 Beta Soon to be added in a new patch file.
### This version has a new patch v7. I have at the moment no working 4k display..
### Please try and use the 4k screen without the patch first, to see if it makes a difference.


If this patch helped you, and you are happy with the result you could consider making a little donation to my PayPal account on (email found here: http://minimind.nl/paypal.html)

# What does this patch resolve?

* makes 4K/3840x2160/UHD/2560x1080/3440x1440 resolutions possible on older macs over both HDMI and DisplayPort. (other odd/high resolutions should also work)
* Enables HDMI2.0 on Nvidia Maxwell cards (Never tested this myself, for this you only need the IOKit patch not the Nvidia patch)

# A few things to keep in mind

* Disable SIP (more info below)
* For Nvidia SIP needs to stay disabled for IOKit it can be enabled again after patching
* Nvidia patch needs IOKit patch to be effective (maybe not always)
* If using an adapter make sure this is not the problem.
* For different issue's first look trough open and closed issues on this repository and the original repository or open a new one.
* This list will get longer when i have time to gather all the regular issues.

This patch needs MD5's to identify IOKit and Nvidia driver files, if your version is not yet added to the script you can run "XXXX-patcher.command md5" and post them in a new issue, this way i can add them.

If you have a new version of IOKit or Nvidia driver that is not yet supported you can run the command and choose the patch version yourself. for Nvidia there are now 2 versions, so most likely you need v2 for IOKit there are 6 versions so for new IOKit's you most likely need v6. use the command like ```XXXX-patcher.command patch v6``` Most of the time this will work, but use this function carefully.

How to use
=

1. Download the patch you need
2. run ```chmod +x XXXX-patcher.command``` (this makes it executable)
3. run the script ```~/Downloads/XXXX-patcher.command``` if you use ```~/Downloads/XXXX-patcher.command help``` you will get a little bit of information about the script and the functions it has. (dragging the file into the terminal window will also work)

If you wan't to request new functions for this script feel free to open an issue with the request.

##### Some information on SIP

First make sure SIP (System Integrity Protection) is turned off for this to work.
You can disable/enable this only when you boot into the recovery partition.
If you booted into the recovery partition and open the terminal you use ```csrutil disable``` to disable, ```csrutil enable``` to enable and ```csrutil status``` to check the status of SIP you can also check the status on your normal system.
the changes to SIP are only visible in the terminal after a reboot, so it will still notify you that SIP is on when you disable it and run ```csrutil status``` right after it.

SIP can safely be enabled after the patch of the IOKit, if you also want to use an Nvidia/AMD driver that has been patched you need to keep SIP disabled. this is because SIP will not allow you to run drivers which have a broken or no codesignature. by patching the driver we obviously break the codesignature.
kexts are not signable by anyone but apple and trusted parties. so SIP needs to be off for them to load.
IOKit is not a kernel extension and therefore must be codesigned to run, this is done with the wildcard certificat, unique to everyone. even with SIP disabled the IOKit will not run without this new codesignature. the script takes care of the codesigning of the IOKit. 
