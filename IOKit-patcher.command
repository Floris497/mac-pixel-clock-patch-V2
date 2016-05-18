#!/bin/sh

thiscommand=$0

# change for debug purposes
IOKitLocation="/System/Library/Frameworks/IOKit.framework/Versions/A/IOKit"

# for development
# IOKitLocation="/Users/user/Desktop/IOKit"

# Current IOKit md5 Checksum
IOKitCurrent="$(md5 -q $IOKitLocation)"

# Current IOKit md5 Checksum of the '(__DATA,__data)' section expoted by otool
# This makes it possable to detect a patch regardless of the signing certificate
oToolIOKitCurrent="$(otool -t $IOKitLocation |tail -n +2 |md5 -q)"

# md5 checksums of unpatched IOKit files

IOKitUnpatched=(
  b1e6fb797d7d3470acabe7c06e6c139e '10.7.4' 1
  0176a6d9a7c3b8c39bb06785fcdfca6d '10.7.5' 1
  9bf853999cff6ee4158d3fa2acc0ce7c '10.8.3' 2
  233a4256b845b647b151739c87070695 '10.8.4' 2
  5d69bf9227997dfad5e48fa87bd14598 '10.8.5' 2
  d085445f30410008593a65ef4b5f9889 '10.9.1' 3
  9804392bbe8ba4b589175be56889c6c7 '10.9.2' 3
  9a86b6708569360f3156b53cc4f205d9 '10.9.3' 3
  6105cc8f503b589f8b3ce2d3917ad150 '10.9.4' 4
  2a8cbc2f6616d3f7a5e499bd2d5593ab '10.10.0' 5
  a94dc8e1b6bb6491e5f610f0a3caf960 '10.10.2' 5
  29d7632362b2fa4993156717671a5642 '10.10.3 - 10.10.5' 5
  7359b413a4dca7a189b80da750ce43dd '10.11.1' 6
  # a7afb2dd9df1e4c48f12b4b52f7da212 '10.11.2' 6
  # 3cec8ae287ee52a3622082bfc049bb86 '10.11.3' 6
)

# md5 checksums of patched IOKit files
IOKitPatched=(
  92eb38917f6ec4f341bff6fd1b6076ed '10.7.4'
  b5b15d1ed5a404962bc7de895a0df56a '10.7.5'
  289039239535c91146518c64aea5907b '10.8.3'
  8c70a0ca62bf65e9ffa8667e2871c287 '10.8.4'
  de3ad8279077c675ae8093193deb253f '10.8.5'
  0962001659a2031c2425206d9239bda4 '10.9.1'
  45d8fc0e1210f0672297a7716478990e '10.9.2'
)

# md5 checksum of '(__DATA,__data)' section exported by otool from unpatched IOKits
# for future use of detecting a false patch, where the executible's checksum is changed by codesigning but not the actual code.
oToolIOKitUnpatched=(
  29c6568524738576b2ec6e11cfdaa88c '10.10.5' 5
  a224cbca101477adc660f69ce5bbe3ba '10.11.1 beta' 6
  e70f3a302a6f87190e6d6fe7609cb4b5 '10.11.2 and 10.11.3' 6
  769a955b82a16fde0f1ae41eb4bdff7f '10.11.4' 6
  d8829f2234464985863c7a501c288547 '10.11.5' 6
)

# md5 checksum of '(__DATA,__data)' section exported by otool from patched IOKits
oToolIOKitPatched=(
  097a9a5527f0882b6400432c138481bf '10.10.5'  
  e51fd1376c9c32e5b186062a132a4f20 '10.11'
  422c441e207a011b355f712fc0ff7fba '10.11.2 and 10.11.3'
  637f064f5d76492f7ac5479e6554caa6 '10.11.4'
  5ff1819545b8e127728a904c8f41bc5f '10.11.5'
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
  printf "more info: https://developer.apple.com/library/prerelease/mac/documentation/Security/Conceptual/System_Integrity_Protection_Guide/ConfiguringSystemIntegrityProtection/ConfiguringSystemIntegrityProtection.html\n"
}

function help {
  printf "using this script without input will patch IOKit if supported version found\n"
  printf "patch [v1-v6]\t patch on a specific version\n"
  printf "\t\t eg. $(basename $thiscommand) patch v3\n"
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

function IOKitPatch {
  testSIP
  
  case "$1" in
  1)  printf "Patching IOKit with patch version 1\n"
      sudo perl -i.bak -pe '$before = qr"\xF6\xC1\x01\x74\x0A"s;s/$before/\xE9\x71\x03\x00\x00/g' $IOKitLocation
      sudo touch /System/Library/Extensions
      ;;
  2)  printf "Patching IOKit with patch version 2\n"
      sudo perl -i.bak -pe '$before = qr"\x0F\x85\xDE\x03\x00\x00"s;s/$before/\xE9\xC5\x03\x00\x00\x90/g' $IOKitLocation
      sudo touch /System/Library/Extensions
      ;;
  3)  printf "Patching IOKit with patch version 3\n"
      sudo perl -i.bak -pe '$before = qr"\x0F\x85\x9D\x03\x00\x00"s;s/$before/\xE9\x84\x03\x00\x00\x90/g' $IOKitLocation
      sudo touch /System/Library/Extensions
      ;;
  4)  printf "Patching IOKit with patch version 4\n"
      sudo perl -i.bak -pe '$before = qr"\x0F\x85\x9D\x03\x00\x00"s;s/$before/\xE9\x84\x03\x00\x00\x90/g' $IOKitLocation
      sudo touch /System/Library/Extensions
      printf "Re-singing $IOKitLocation\n"
      sudo codesign -f -s - $IOKitLocation
      ;;
  5)  printf "Patching IOKit with patch version 5\n"
      sudo perl -i.bak -pe '$before = qr"\x0F\x85\x9E\x03\x00\x00"s;s/$before/\xE9\x83\x03\x00\x00\x90/g' $IOKitLocation
      sudo touch /System/Library/Extensions
      printf "Re-singing $IOKitLocation\n"
    	sudo codesign -f -s - $IOKitLocation
      ;;
  6)  printf "Patching IOKit with patch version 6\n"
      sudo perl -i.bak -pe '$before = qr"\x0F\x85\x92\x03\x00\x00"s;s/$before/\xE9\x7A\x03\x00\x00\x90/g' $IOKitLocation
      sudo touch /System/Library/Extensions
      printf "Re-singing $IOKitLocation\n"
      sudo codesign -f -s - $IOKitLocation
      ;;
  *)  printf "This patch does not exist, make sure you used the right patch identfier\n"
      exit
      ;;
  esac
}

function IOKitUnpatch {
  testSIP
  
  if [[ -f "$IOKitLocation.bak" ]]; then
    printf "Moving backup file back in place"
    sudo mv $IOKitLocation.bak $IOKitLocation
  else 
    printf "No backup found, the patch has either not been done, or the backup file has been deleted.."
  fi
}

function IOKitPrintAllMD5 {
  echo "---- BEGINNING MD5 HASH SUMS ---- version: $(sw_vers -productVersion) build:$(sw_vers -buildVersion)"
  echo
  printf "     otool IOKit: $(otool -t $IOKitLocation |tail -n +2 |md5 -q)\n"
  if [[ -f "$IOKitLocation.bak" ]]; then
    printf " otool IOKit.bak: $(otool -t $IOKitLocation.bak |tail -n +2 |md5 -q)\n"
  else
    printf " otool IOKit.bak: NO FILE (this is okay)\n"
  fi
  printf "           IOKit: $(md5 -q $IOKitLocation)\n"
  if [[ -f "$IOKitLocation.bak" ]]; then
    printf "       IOKit.bak: $(md5 -q $IOKitLocation.bak)\n"
  else
    printf "       IOKit.bak: NO FILE (this is okay)\n"
  fi
  echo
  echo "---- ENDING MD5 HASH SUMS -------"
}

function testIOKitPatch {
  if [[ ! -f "$IOKitLocation.bak" ]]; then
    echo "Patch failed to run"
  elif [[ $(otool -t $IOKitLocation.bak |tail -n +2 |md5 -q) !=  $(otool -t $IOKitLocation |tail -n +2 |md5 -q) ]]; then
    echo "The code of IOKit changed, the patch was probbably succesfull"
  else
    echo "The code is still the same.. Patch did seem to run, but was probbably from the wrong version.."
    echo "If you are running an new os run $thiscommand md5 and ask the maintainer of this script to add support for your system"
  fi

}

function test {
  testSIP
  printf "\n"
  nothingWasFound=true;
  for ((i=0; i < ${#IOKitUnpatched[@]}; i+=3)); do
    if [[ $IOKitCurrent == ${IOKitUnpatched[$i]} ]]; then
      printf "Detected unpatched IOKit on OS X %s.\n" "${IOKitUnpatched[$i+1]}"
      nothingWasFound=false
      if [[ ! -z $1 ]]; then
        if [[ $1 == "patch" ]]; then
          IOKitPatch ${IOKitUnpatched[$i+2]}
          makeExit
        fi
      fi
    fi
  done
  for ((i=0; i < ${#oToolIOKitUnpatched[@]}; i+=3)); do
    if [[ $oToolIOKitCurrent == ${oToolIOKitUnpatched[$i]} ]]; then
      printf "(otool) Detected unpatched IOKit on OS X %s.\n" "${oToolIOKitUnpatched[$i+1]}"
      nothingWasFound=false
      if [[ ! -z $1 ]]; then
        if [[ $1 == "patch" ]]; then
          IOKitPatch ${oToolIOKitUnpatched[$i+2]} 
          makeExit
        fi
      fi
    fi
  done
  for ((i=0; i < ${#IOKitPatched[@]}; i+=2)); do
    if [[ $IOKitCurrent == ${IOKitPatched[$i]} ]]; then
      printf "Detected patched IOKit on OS X %s.\n" "${IOKitPatched[$i+1]}"
      nothingWasFound=false
    fi
  done
  for ((i=0; i < ${#oToolIOKitPatched[@]}; i+=2)); do
    if [[ $oToolIOKitCurrent == ${oToolIOKitPatched[$i]} ]]; then
      printf "(otool) Detected patched IOKit on OS X %s.\n" "${oToolIOKitPatched[$i+1]}"
      nothingWasFound=false
    fi
  done
  if $nothingWasFound; then
    echo "Unknown version of IOKit found.."
    IOKitPrintAllMD5
  fi
}


function options {
  if [[ $1 == "patch" ]]; then
    #test if there is a backup file
    if [[ -f "$IOKitLocation.bak" ]]; then
      printf "An backup file already exists, if you force this patch on an already patched version you will loose the original backup!\n"
      printf "This will lead you to reinstall the OS if you loose a working version of IOKit. be carefull\n"
      printf "It might be wise to undo the patch before trying to redo it using: $thiscommand unpatch\n"
      askExit
    fi
    if [[ -z $2 ]]; then
      printf "Did not specify patch version\n"
      makeExit
    fi
    case "$2" in
      v1) IOKitPatch 1;;
      v2) IOKitPatch 2;;
      v3) IOKitPatch 3;;
      v4) IOKitPatch 4;;
      v5) IOKitPatch 5;;
      v6) IOKitPatch 6;;
      *)  IOKitPatch 0;;
    esac
    testIOKitPatch 
    exit 
  elif [[ $1 == 'unpatch' ]]; then
    if [[ ! -f "$IOKitLocation.bak" ]]; then
      printf "There is no backup file, we can not undo the patch. the patch might not even been done.\n"
      makeExit
    fi
    IOKitUnpatch
  elif [[ $1 == 'test' ]] || [[ $1 == 'status' ]]; then
    test
    exit
  elif [[ $1 == 'md5' ]]; then
    IOKitPrintAllMD5
    exit
  elif [[ $1 == 'help' ]]; then
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
