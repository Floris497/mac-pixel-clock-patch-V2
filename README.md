# mac-pixel-clock-patch-V2 ALPHA

Based on (https://github.com/floris497/mac-pixel-clock-patch). [original](https://code.google.com/p/mac-pixel-clock-patch/wiki/Documentation)

for more info look at the old patch: https://github.com/floris497/mac-pixel-clock-patch

If this patch helped you, and you are happy with the result you could consider making a little donation to my PayPal account on (email found here: http://minimind.nl/paypal.html)

#### this patch is still in development, as far as i know it's pretty stable, but fairly untested. If you see big or little mistakes in this patch please let me know by either making an issue or fork this patch and make it even better.

#### for now only IOKit. (AMD and Nvidia will get their own similar patch file later)

For this patch to work on as many systems as possible i need to gather MD5 hashes of the IOKit files, if your version of IOKit is not yet supported run ```XXXX-patcher.command md5``` and make a new issue to give me the md5's i need to improve the reach of this patch.

If you feel adventurous and the patch for your IOKit is not yet available yet, you can use ```XXXX-patcher.command patch <vX>``` (```<vX>``` must be replaced with something like v6 which is currently the latest version) this way you can try and patch with an older patch. this will work often, the script will notify you if it was successful or not. if this works please run ```XXXX-patcher.command md5``` and notify me of your MD5's.

If your version is available but it does not detect it is patched the script probably does not contain an identification MD5 for your version of IOKit yet, if you run ```XXXX-patcher.command md5``` and provide me the MD5's, I can add those too.

how to use
=====

#####MAKE SURE TO DISABLE SIP on OS X 10.11 and newer.

First make sure SIP (System Integrity Protection) is turned off for this to work.
You can disable/enable this only when you boot into the recovery partition.
If you booted into the recovery partition and open the terminal you use ```csrutil disable``` to disable, ```csrutil enable``` to enable and ```csrutil status``` to check the status of SIP you can also check the status on your normal system.
the changes to SIP are only visible in the terminal after a reboot, so it will still notify you that SIP is on when you disable it and run ```csrutil status``` right after it.

SIP can safely be enabled after the patch of the IOKit, if you also want to use an Nvidia/AMD driver that has been patched you need to keep SIP disabled. this is because SIP will not allow you to run drivers which have a broken or no codesignature. by patching the driver we obviously break the codesignature.
kernal extensions are not signable by anyone but apple and trusted parties. so SIP needs to be off for them to load.
IOKit is not a kernel extension and therefore must be codesigned to run, this is done with the wildcard certificat, unique to everyone. even with SIP disabled the IOKit will not run without this new codesignature. the script takes care of the codesigning of the IOKit. 

1: Download the patch you need
2: run ```chmod +x XXXX-patcher.command``` (this makes it runable)
3: run the script ```~/Downloads/patcher.script``` if you use ```~/Downloads/XXXX-patcher.command help``` you will get a little bit of information about the script and the functions it has. (dragging the file into the terminal window will also work)



