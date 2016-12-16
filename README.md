# mac-pixel-clock-patch-V2

Based on [my fork of the repository](https://github.com/floris497/mac-pixel-clock-patch) and [the original project which is hosted on google code](https://code.google.com/p/mac-pixel-clock-patch/wiki/Documentation)

## CoreDisplay 10.12.2 now supported by script (10.12 does not work for everyone that used 10.11 succesfully)

## Do not unpatch after updating!!! When updating the backup is not removed. unpatching will result in the old backup to be made active this means you will loose your current CoreDisplay driver and you won't have a backup.

## For 10.12 and up please use the CoreDisplay patched insetad of IOKit. Pixel clock has been moved.

If this patch helped you, and you are happy with the result you could consider making a little donation to my PayPal account on (email found here: http://minimind.nl/paypal.html)

# What does this patch resolve?

* makes 4K/3840x2160/UHD/2560x1080/3440x1440 resolutions possible on older macs over both HDMI and DisplayPort. (other odd/high resolutions should also work)
* Enables HDMI2.0 on Nvidia Maxwell cards (Never tested this myself, for this you only need the IOKit patch not the Nvidia patch)

# A few things to keep in mind

* Disable SIP ([more info below](#some-information-on-sip))
* For Nvidia SIP needs to stay disabled for IOKit it can be enabled again after patching
* Nvidia patch needs IOKit patch to be effective (maybe not always)
* If using an adapter make sure this is not the problem.
* For different issue's first look trough open and closed issues on this repository and the original repository or open a new one.
* This list will get longer when i have time to gather all the regular issues.

This patch needs MD5's to identify IOKit and Nvidia driver files, if your version is not yet added to the script you can run "XXXX-patcher.command md5" and post them in a new issue, this way i can add them.

If you have a new version of IOKit or Nvidia driver that is not yet supported you can run the command and choose the patch version yourself. for Nvidia there are now 2 versions, so most likely you need v2 for IOKit there are 6 versions so for new IOKit's you most likely need v6. use the command like ```XXXX-patcher.command patch v6``` Most of the time this will work, but use this function carefully.

What patch do i need
=
The table might not be fully correct, also not all mac's are supported with this patch.

| PATCH               | Intel HD Graphics 10.11 and below | Nvidia Mobile Graphics 10.11 and below | AMD Graphics | Nvidia Dedicated Graphics 10.11 and below | Intel HD Graphics 10.12 and newer | Nvidia Mobile Graphics 10.12 and newer | Nvidia Dedicated Graphics 10.12 and newer |
|---------------------|-----------------------------------|----------------------------------------|--------------|-------------------------------------------|-----------------------------------|----------------------------------------|-------------------------------------------|
| IOKit Patcher       | YES                               | YES                                    | Not Working  | YES                                       | NO                                | NO                                     | NO                                        |
| CoreDisplay Patcher | NO                                | NO                                     | Not Working  | NO                                        | YES                               | YES                                    | YES                                       |
| Nvidia Patcher      | NO                                | YES                                    | N/A          | NO                                        | NO                                | YES                                    | NO                                        |


How to use
=

Everywhere where you see `~/Downloads/XXXX-patcher.command` you can add

0. before you start make sure SIP is disabled. ([Info about SIP](#some-information-on-sip))

1. Download the patch(es) you need to your downloads folder: ([IOKit](./IOKit-patcher.command), [CoreDisplay](./CoreDisplay-patcher.command), [Nvidia](./Nvidia-patcher.command))
2. open the Terminal (found at /Applications/Utilities/Terminal.app)
3. run `chmod +x ~/Downloads/XXXX-patcher.command` (this makes the patch executable)
4. run the script `~/Downloads/XXXX-patcher.command`
5. follow the instructions and fill you password when asked for
6. (if you need more than 1 patch, go back to step 3 here and continue with the next patch there)
7. reboot your machine

Next steps are not necessary for everyone:
8. get switchresx and install it.
9. add the custom resolution you need.
10. save it and reboot your machine.

extra functions: ```~/Downloads/XXXX-patcher.command md5|status|patch (v1-vX)|unpatch|help``` for instance used like: ```~/Downloads/IOKit-patcher.command patch v7``` or ```~/Downloads/Nvidia-patcher.command unpatch```

If you wan't to request new functions for this script feel free to open an issue with the request.

### Some information on SIP

First make sure SIP (System Integrity Protection) is turned off for this to work.
You can disable/enable this only when you boot into the recovery partition.
If you booted into the recovery partition and open the terminal you use ```csrutil disable``` to disable, ```csrutil enable``` to enable and ```csrutil status``` to check the status of SIP you can also check the status on your normal system.
the changes to SIP are only visible in the terminal after a reboot, so it will still notify you that SIP is on when you disable it and run ```csrutil status``` right after it.

SIP can safely be enabled after the patch of the IOKit, if you also want to use an Nvidia/AMD driver that has been patched you need to keep SIP disabled. this is because SIP will not allow you to run drivers which have a broken or no codesignature. by patching the driver we obviously break the codesignature.
kexts are not signable by anyone but apple and trusted parties. so SIP needs to be off for them to load.
IOKit is not a kernel extension and therefore must be codesigned to run, this is done with the wildcard certificate, unique to everyone. even with SIP disabled the IOKit will not run without this new codesignature. the script takes care of the codesigning of the IOKit.
