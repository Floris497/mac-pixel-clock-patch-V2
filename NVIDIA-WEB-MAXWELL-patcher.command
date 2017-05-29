#!/bin/sh

thiscommand=$0

# location of the driver executable
NVDALocation="/System/Library/Extensions/NVDAGP100HalWeb.kext/Contents/MacOS/NVDAGP100HalWeb"

# for development
# NVDALocation="/Users/user/Desktop/NVDAGK100Hal"

NVDABasename="$(basename $NVDALocation)"

# Current Nvidia md5 Checksum
NVDACurrent="$(md5 -q $NVDALocation)"

# md5 checksums of unpatched Nvidia files

NVDAMD5Unpatched=(
  0ee0407775db6da70015dbcc75780e66 'nvidia web: 378.05.05.05f02 (10.17.34)' 1
  cbe4cf2687f7828c64a1698a910ae124 'nvidia web: 378.05.05.15f01 (10.18.5)' 1
)

# md5 checksums of patched Nvidia files
NVDAMD5Patched=(
  096a081347024086efa8d396d814afd0 'nvidia web: 378.05.05.05f02 (10.17.34)'
  0ee0407775db6da70015dbcc75780e66 'nvidia web: 378.05.05.15f01 (10.18.5)'
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
  printf "\t\t eg. $(basename $thiscommand) patch v2 (v3 experimental)\n"
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
  	  sudo perl -i.bak -pe '$oldLimit1 = qr"\x8B\x82\xB0\x00\x00\x00\xB9\x88\x84\x02\x00"s;$newLimit1 = "\x8B\x82\xB0\x00\x00\x00\xB9\x00\x35\x0C\x00";s/$oldLimit1/$newLimit1/g' $NVDALocation
      sudo touch /System/Library/Extensions
      ;;
  *)  printf "This patch does not exist, make sure you used the right patch identifier\n"
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
    echo "The code of the driver has changed, the patch was probably successful"
  else
    echo "The code is still the same.. Patch did seem to run, but was probably from the wrong version.."
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
      printf "This will lead you to reinstall the OS if you loose a working version of the driver. be careful!\n"
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
	  v3) NVDAPatch 3;;
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
