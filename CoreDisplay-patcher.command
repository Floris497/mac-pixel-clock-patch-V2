#!/bin/sh

thiscommand=$0

# change for debug purposes
CoreDisplayLocation="/System/Library/Frameworks/CoreDisplay.framework/Versions/A/CoreDisplay"

# for development
# CoreDisplayLocation="/Users/user/Desktop/CoreDisplay"

# Current CoreDisplay md5 Checksum
CoreDisplayCurrent="$(md5 -q $CoreDisplayLocation)"

# Current CoreDisplay md5 Checksum of the '(__DATA,__data)' section expoted by otool
# This makes it possable to detect a patch regardless of the signing certificate
oToolCoreDisplayCurrent="$(otool -t $CoreDisplayLocation |tail -n +2 |md5 -q)"

# md5 checksum of '(__DATA,__data)' section exported by otool from unpatched CoreDisplays
# for future use of detecting a false patch, where the executible's checksum is changed by codesigning but not the actual code.
oToolCoreDisplayUnpatched=(
  49cd8062ed1c8f610b71e9a3231cf804 '10.12 16A254g' 1
  8e1030235b90d6ab0644bd7a1b6f9cdb '10.12 16A284a' 1
  f4c6e84ffa97e06624e5504edd87bf7d '10.12 16A284a' 1 # I don't know why these two are different
  4cba52b41ceee7bc658020c9e58780a3 '10.12 16A294a' 1
  d41d8cd98f00b204e9800998ecf8427e '10.12 16A313a' 1
  aa7607dd72a2a4ca70ce094a2fc39cce '10.12  ' 1  # Sierra 10.12 release
  172b7e2fe2e45e99b078e69684dd3c10 '10.12.1' 2
  9c717568024daa81c364a839f09a1bfd '10.12.2 16C67' 3
)

# md5 checksum of '(__DATA,__data)' section exported by otool from patched CoreDisplays
oToolCoreDisplayPatched=(
  4e469fbf1c36d96fc25fb931c6670649 '10.12 16A254g'
  b6ee4943c2fce505faceb568e1c8f4b1 '10.12 16A284a'
  82f97933a3ae90d47054316fa8259f6c '10.12 16A284a'
  1371f71ca7949cfbe01ede8e8b52e61d '10.12 16A294a'
  f9c185d9e4c4ba12d5ecf41483055e39 '10.12 16A313a'
  eb27b5d68e9fb15aa65ea0153637eae2 '10.12  '  # Sierra 10.12 release
  cf8373138af4671a561c1a4d6cdba771 '10.12.1'
  e9d7a42b6613a45a69a41e8099d0e369 '10.12.2 16C67' 3
)

function makeExit {
  printf "Closing..\n"
  exit
}

function askExit {
  read -p "Do you want to continue? [Y/n] " -n 1 -r
  echo 
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    makeExit
  fi
}
  
function SIPInfo {
  printf "more info: Google 'SIP'\n"
}

function help {
  printf "using this script without input will patch CoreDisplay if supported version found\n"
  printf "patch [v1-v3]\t patch on a specific version\n"
  printf "\t\t eg. $(basename $thiscommand) patch v2\n"
  printf "unpatch\t\t undo patch\n"
  printf "status\t\t Shows you if you have an known or unknown patch\n"
  printf "md5\t\t gives all your md5 hashes\n"
  printf "help\t\t show this help message\n"
}

function testSIP {
  if hash csrutil 2>/dev/null; then
    if [[ "$(csrutil status | head -n 1)" == *"status: enabled (Custom Configuration)"* ]]; then
      printf "SIP might or might not be disabled\n"
      printf "the script might or might not be working\n"
      printf "check \"\$ csrutil status\"\n"
      SIPInfo
      askExit
    elif [[ "$(csrutil status | head -n 1)" == *"status: enabled"* ]]; then
      printf "SIP is enabled, this script will only work if SIP is disabled\n"
      makeExit
    elif [[ "$(csrutil status | head -n 1)" == *"status: disabled"* ]]; then
      printf "SIP looks to be disabled, all good!\n"
    fi
  fi  
}

function CoreDisplayPatch {
  testSIP
  case "$1" in
  1)  printf "Patching CoreDisplay with patch version 1\n"
      	sudo perl -i.bak -pe '$before = qr"\xB8\x01\x00\x00\x00\xF6\xC1\x01\x0F\x85\x05\x04\x00\x00"s;s/$before/\x31\xC0\x90\x90\x90\x0F\x1F\x00\xE9\x06\x04\x00\x00\x90/g' $CoreDisplayLocation
	  	sudo touch /System/Library/Extensions
	  	printf "Re-singing $CoreDisplayLocation\n"
	  	sudo codesign -f -s - $CoreDisplayLocation
	  	;;
  2)  printf "Patching CoreDisplay with patch version 2\n"
		sudo perl -i.bak -pe '$before = qr"\xB8\x01\x00\x00\x00\xF6\xC1\x01\x0F\x85\x96\x04\x00\x00"s;s/$before/\x31\xC0\x90\x90\x90\x90\x90\x90\xE9\x97\x04\x00\x00\x90/g' $CoreDisplayLocation
	 	sudo touch /System/Library/Extensions
	  	printf "Re-singing $CoreDisplayLocation\n"
	  	sudo codesign -f -s - $CoreDisplayLocation
	  	;;
  3)  printf "Patching CoreDisplay with patch version 3\n"
  		sudo perl -i.bak -pe '$before = qr"\xB8\x01\x00\x00\x00\xF6\xC1\x01\x0F\x85\xAD\x04\x00\x00"s;s/$before/\x31\xC0\x90\x90\x90\x90\x90\x90\xE9\xAE\x04\x00\x00\x90/g' $CoreDisplayLocation
	  	sudo touch /System/Library/Extensions
	  	printf "Re-singing $CoreDisplayLocation\n"
	  	sudo codesign -f -s - $CoreDisplayLocation
	  	;;
  *)  printf "This patch does not exist, make sure you used the right patch identfier\n"
      exit
      ;;
  esac
}

function CoreDisplayUnpatch {
  testSIP
  
  if [[ -f "$CoreDisplayLocation.bak" ]]; then
    printf "Moving backup file back in place\n"
    sudo mv $CoreDisplayLocation.bak $CoreDisplayLocation
  else 
    printf "No backup found, the patch has either not been done, or the backup file has been deleted.."
  fi
}

function CoreDisplayPrintAllMD5 {
  echo "---- BEGINNING MD5 HASH SUMS ---- version: $(sw_vers -productVersion) build:$(sw_vers -buildVersion)"
  echo
  printf "     otool CoreDisplay: $(otool -t $CoreDisplayLocation |tail -n +2 |md5 -q)\n"
  if [[ -f "$CoreDisplayLocation.bak" ]]; then
    printf " otool CoreDisplay.bak: $(otool -t $CoreDisplayLocation.bak |tail -n +2 |md5 -q)\n"
  else
    printf " otool CoreDisplay.bak: NO FILE (this is okay)\n"
  fi
  printf "           CoreDisplay: $(md5 -q $CoreDisplayLocation)\n"
  if [[ -f "$CoreDisplayLocation.bak" ]]; then
    printf "       CoreDisplay.bak: $(md5 -q $CoreDisplayLocation.bak)\n"
  else
    printf "       CoreDisplay.bak: NO FILE (this is okay)\n"
  fi
  echo
  echo "---- ENDING MD5 HASH SUMS -------"
}

function testCoreDisplayPatch {
  if [[ ! -f "$CoreDisplayLocation.bak" ]]; then
    echo "Patch failed to run"
  elif [[ $(otool -t $CoreDisplayLocation.bak |tail -n +2 |md5 -q) !=  $(otool -t $CoreDisplayLocation |tail -n +2 |md5 -q) ]]; then
    echo "The code of CoreDisplay changed, the patch was probbably succesfull"
  else
    echo "The code is still the same.. Patch did seem to run, but was probbably from the wrong version.."
    echo "If you are running an new os run $thiscommand md5 and ask the maintainer of this script to add support for your system"
  fi

}

function test {
  testSIP
  printf "\n"
  nothingWasFound=true;
  for ((i=0; i < ${#CoreDisplayUnpatched[@]}; i+=3)); do
    if [[ $CoreDisplayCurrent == ${CoreDisplayUnpatched[$i]} ]]; then
      printf "Detected unpatched CoreDisplay on OS X %s.\n" "${CoreDisplayUnpatched[$i+1]}"
      nothingWasFound=false
      if [[ ! -z $1 ]]; then
        if [[ $1 == "patch" ]]; then
          CoreDisplayPatch ${CoreDisplayUnpatched[$i+2]}
          makeExit
        fi
      fi
    fi
  done
  for ((i=0; i < ${#oToolCoreDisplayUnpatched[@]}; i+=3)); do
    if [[ $oToolCoreDisplayCurrent == ${oToolCoreDisplayUnpatched[$i]} ]]; then
      printf "(otool) Detected unpatched CoreDisplay on OS X %s.\n" "${oToolCoreDisplayUnpatched[$i+1]}"
      nothingWasFound=false
      if [[ ! -z $1 ]]; then
        if [[ $1 == "patch" ]]; then
          CoreDisplayPatch ${oToolCoreDisplayUnpatched[$i+2]} 
          makeExit
        fi
      fi
    fi
  done
  for ((i=0; i < ${#CoreDisplayPatched[@]}; i+=2)); do
    if [[ $CoreDisplayCurrent == ${CoreDisplayPatched[$i]} ]]; then
      printf "Detected patched CoreDisplay on OS X %s.\n" "${CoreDisplayPatched[$i+1]}"
      nothingWasFound=false
    fi
  done
  for ((i=0; i < ${#oToolCoreDisplayPatched[@]}; i+=2)); do
    if [[ $oToolCoreDisplayCurrent == ${oToolCoreDisplayPatched[$i]} ]]; then
      printf "(otool) Detected patched CoreDisplay on OS X %s.\n" "${oToolCoreDisplayPatched[$i+1]}"
      nothingWasFound=false
    fi
  done
  if $nothingWasFound; then
    echo "Unknown version of CoreDisplay found.."
    CoreDisplayPrintAllMD5
  fi
}


function options {
  if [[ $1 == "patch" ]]; then
    #test if there is a backup file
    if [[ -f "$CoreDisplayLocation.bak" ]]; then
      printf "An backup file already exists, if you force this patch on an already patched version you will loose the original backup!\n"
      printf "This will lead you to reinstall the OS if you loose a working version of CoreDisplay. be carefull\n"
      printf "It might be wise to undo the patch before trying to redo it using: $thiscommand unpatch\n"
      askExit
    fi
    if [[ -z $2 ]]; then
      printf "Did not specify patch version\n"
      makeExit
    fi
    case "$2" in
      v1) CoreDisplayPatch 1;;
      v2) CoreDisplayPatch 2;;
	  v3) CoreDisplayPatch 3;;
      *)  CoreDisplayPatch 0;;
    esac
    testCoreDisplayPatch 
    exit 
  elif [[ $1 == 'unpatch' ]] || [[ $1 == 'depatch' ]]; then
    if [[ ! -f "$CoreDisplayLocation.bak" ]]; then
      printf "There is no backup file, we can not undo the patch. the patch might not even been done.\n"
      makeExit
    fi
    CoreDisplayUnpatch
  elif [[ $1 == 'test' ]] || [[ $1 == 'status' ]]; then
    test
    exit
  elif [[ $1 == 'md5' ]]; then
    CoreDisplayPrintAllMD5
    exit
  elif [[ $1 == 'help' ]] || [[ $1 == '-h' ]] || [[ $1 == '--help' ]]; then
    help
    exit
  elif [[ -z $1 ]]; then
    test "patch"
    exit
  else
    printf "option is not valid\n"
    printf "\n"
	  help
    exit
  fi
}

# runs the script
options $1 $2
