#!/bin/sh

thiscommand=$0

# location of the driver executible
NVDALocation="/System/Library/Extensions/NVDAGK100Hal.kext/Contents/MacOS/NVDAGK100Hal"

# for development
# NVDALocation="/Users/user/Desktop/NVDAGK100Hal"

NVDABasename="$(basename $NVDALocation)"

# Current Nvidia md5 Checksum
NVDACurrent="$(md5 -q $NVDALocation)"

# md5 checksums of unpatched Nvidia files

NVDAMD5Unpatched=(
  6a2d5017b6ddd3d19de2f4039d4c88ec '10.8.3' 1
  b553fd25b25d2262317e9de758888d2b '10.8.4' 2
  f84d891f1a67aa278453be59a6e1fece '10.8.5' 2
  6de28959ec948513c239b1bf31205465 '10.9.1' 2
  9b584e820da1b7a0a32416d4c6e34886 '10.10.5' 2
  77ad2ec58403088bbe026dd2ada737c0 '10.11' 2
  1ecb016bc5b4ed7b7949d87e4f3f234a '10.11.1' 2
  bb87a13eaabefcafa9e82fad03365aa4 '10.11.2' 2
  4c5aa903f28e3dbcfb2e15d8efdbfcbe '10.11.3' 2
  840234288d56c2171e75083dfdd6b1d9 '10.11.4' 2
  62e429ce9f61893a5b7379b0b0b9839f '10.11.5' 2
)

# md5 checksums of patched Nvidia files
NVDAMD5Patched=(
  7e8372fca35c5e7db90a229e70709d58 '10.8.3'
  3c552ba24fa89b2ea892dd711088e8d5 '10.8.4'
  5e65da83006468e8a69ef60a180ea08d '10.8.5'
  bbb0885323ea3221150839782fbd553f '10.9.1'
  8cc9299149c3ab99fe6def45366ecb40 '10.10.5'
  334875e37ab36a1a9d6a4bde4dce78f5 '10.11'
  b6babc8ca4f03bdb2552bb01c51770b1 '10.11.1'
  3b3244d597be457326d9c19309f00ff0 '10.11.2'
  0530c11c65068c0201505a914f6f0bf6 '10.11.3'
  fa463e9b414b02538e12044c365636a3 '10.11.4'
  bba91da3d3208e36c24c7a64562c6eed '10.11.5'
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
  printf "using this script without input will patch the NVIDIA driver if a supported version found\n"
  printf "patch [v1-v2]\t patch on a specific version\n"
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
  printf "Keep SIP disabled, if enabled again SIP prevent the Nvidia Driver from loading\n"
  fi  
}

function NVDAPatch {
  testSIP
  
  case "$1" in
  1)  printf "Patching $NVDABasename with patch version 1\n"
      sudo perl -i.bak -pe '$oldLimit1 = qr"\xC7\x82\xC8\x00\x00\x00\x88\x84\x02\x00"s;$newLimit1 = "\xC7\x82\xC8\x00\x00\x00\x80\x1A\x06\x00";$oldLimit2 = qr"\xC7\x82\x10\x01\x00\x00\x88\x84\x02\x00"s;$newLimit2 = "\xC7\x82\x10\x01\x00\x00\x80\x1A\x06\x00";s/$oldLimit1/$newLimit1/g;s/$oldLimit2/$newLimit2/g' $NVDALocation
      sudo touch /System/Library/Extensions
      ;;
  2)  printf "Patching $NVDABasename with patch version 2\n"
      sudo perl -i.bak -pe '$oldLimit1 = qr"\xC7\x82\xD0\x00\x00\x00\x88\x84\x02\x00"s;$newLimit1 = "\xC7\x82\xD0\x00\x00\x00\x80\x1A\x06\x00";$oldLimit2 = qr"\xC7\x82\x20\x01\x00\x00\x88\x84\x02\x00"s;$newLimit2 = "\xC7\x82\x20\x01\x00\x00\x80\x1A\x06\x00";s/$oldLimit1/$newLimit1/g;s/$oldLimit2/$newLimit2/g' $NVDALocation
      sudo touch /System/Library/Extensions
      ;;
  *)  printf "This patch does not exist, make sure you used the right patch identfier\n"
      exit
      ;;
  esac
}

function NVDAUnpatch {
  testSIP

  if [[ -f "$NVDALocation.bak" ]]; then
    printf "Moving backup file back in place\n"
    sudo mv $NVDALocation.bak $NVDALocation
  else
    printf "No backup found, the patch has either not been done, or the backup file has been deleted.."
  fi
}

function NVDAPrintAllMD5 {
  echo "---- BEGINNING MD5 HASH SUMS ---- version: $(sw_vers -productVersion) build:$(sw_vers -buildVersion)"
  echo
  printf "     $NVDABasename: $(md5 -q $NVDALocation)\n"
  if [[ -f "$NVDALocation.bak" ]]; then
    printf " $NVDABasename.bak: $(md5 -q $NVDALocation.bak)\n"
  else
    printf " $NVDABasename.bak: NO FILE (this is okay)\n"
  fi
  echo
  echo "---- ENDING MD5 HASH SUMS -------"
}

function testNVDAPatch {
  if [[ ! -f "$NVDALocation.bak" ]]; then
    echo "Patch failed to run"
  elif [[ $(md5 -q $NVDALocation.bak) !=  $(md5 -q $NVDALocation) ]]; then
    echo "The code of the driver has changed, the patch was probbably succesfull"
  else
    echo "The code is still the same.. Patch did seem to run, but was probbably from the wrong version.."
    echo "If you are running an new os run $thiscommand md5 and ask the maintainer of this script to add support for your system"
  fi

}

function test {
  testSIP
  printf "\n"
  nothingWasFound=true;
  for ((i=0; i < ${#NVDAMD5Unpatched[@]}; i+=3)); do
    if [[ $NVDACurrent == ${NVDAMD5Unpatched[$i]} ]]; then
      printf "Detected unpatched Nvidia driver on OS X %s.\n" "${NVDAMD5Unpatched[$i+1]}"
      nothingWasFound=false
      if [[ ! -z $1 ]]; then
        if [[ $1 == "patch" ]]; then
          NVDAPatch ${NVDAMD5Unpatched[$i+2]}
          makeExit
        fi
      fi
    fi
  done
  for ((i=0; i < ${#NVDAMD5Patched[@]}; i+=2)); do
    if [[ $NVDACurrent == ${NVDAMD5Patched[$i]} ]]; then
      printf "Detected patched Nvidia driver on OS X %s.\n" "${NVDAMD5Patched[$i+1]}"
      nothingWasFound=false
    fi
  done
  if $nothingWasFound; then
    echo "Unknown version of the Nvidia driver found.."
    NVDAPrintAllMD5
  fi
}


function options {
  if [[ $1 == "patch" ]]; then
    #test if there is a backup file
    if [[ -f "$NVDALocation.bak" ]]; then
      printf "An backup file already exists, if you force this patch on an already patched version you will loose the original backup!\n"
      printf "This will lead you to reinstall the OS if you loose a working version of the driver. be carefull!\n"
      printf "It might be wise to undo the patch before trying to redo it using: $thiscommand unpatch\n"
      askExit
    fi
    if [[ -z $2 ]]; then
      printf "Did not specify patch version\n"
      makeExit
    fi
    case "$2" in
      v1) NVDAPatch 1;;
      v2) NVDAPatch 2;;
      *)  NVDAPatch 0;;
    esac
    testNVDAPatch
    exit 
  elif [[ $1 == 'unpatch' ]]; then
    if [[ ! -f "$NVDALocation.bak" ]]; then
      printf "There is no backup file, we can not undo the patch. the patch might not even been done.\n"
      makeExit
    fi
    NVDAUnpatch
  elif [[ $1 == 'test' ]] || [[ $1 == 'status' ]]; then
    test
    exit
  elif [[ $1 == 'md5' ]]; then
    NVDAPrintAllMD5
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
