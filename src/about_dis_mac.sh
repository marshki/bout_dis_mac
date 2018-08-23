#!/bin/bash
# mjk 2018.07.09

#############################################################
##  CLI alternative to OS X's "About this Mac" feature.    ##
##  Retrieve information about: OS X "marketing" name;     ##
##  OS version number; hardware model; processor; memory;  ##
##  startup disk; graphics; and serial number.             ##
#############################################################

#############################################################
## This script frequently calls                            ##
## OS X's system_profiler to poll a data type, e.g.:       ##
## system_profiler SP_Some_DataType \                      ##
## | awk '/string_to_extract/{ sub(/^.*: /, ""); print; }')##
## where the output of the profiler is piped to `awk`;     ##
## a search string is extracted;                           ##
## and characters to the right of `:` are printed          ##
#############################################################

#### Lookup table for OS X marketing names ####

MARKETING_NAME=(
["10"]="Yosemite"
["11"]="El Capitan"
["12"]="Sierra"
["13"]="High Sierra"
)

#### Display header message ####

write_header() {
  local name=$1; shift;
  printf "%s\\n""--------------------\\n$name%s\\n--------------------\\n"
  printf "%s\\n" "$@"
}

#### Retrieve Apple's marketing name for installed operating system.  ####
# Take the number extracted from osx_number; use it as a reference
# Check if the number extracted is in array; if it is print marketing name

osx_name () {
  
  local osx_number 
  osx_number=$(sw_vers -productVersion| awk -F '[.]' '{print $2}')
 
  if [[ -n "${MARKETING_NAME[$osx_number]}" ]]; then 
    local osx_name
    osx_name="${MARKETING_NAME[$osx_number]}"    
fi
  
  write_header "OS X Name" "$osx_name"
}

####  Retrieve operating system version  ####

operating_system () {

  local os  
  os=$(sw_vers -productVersion)

  write_header "OS Version" "$os"
}

##### Retrieve hardware model ####
#### --> awk can probably do this better <--####
# read plist & extract 'CPU Names';
# cut string inside of '"' (4th field)
# print only unique string (no dupes)

hardware_model () {

  local hardware_mod
  hardware_mod=$(defaults read ~/Library/Preferences/com.apple.SystemProfiler.plist 'CPU Names' \
  | cut -sd '"' -f 4 \
  | uniq)

  write_header "Hardware Model" "$hardware_mod"
}

#### Retrieve processor information  ####
# awk to extract Processor{Name,Speed}
# sort so numeric comes first
# xargs to print to single line

processor () {

  local cpu  
  cpu=$(system_profiler SPHardwareDataType \
  | awk '/Processor (Name|Speed):/ { sub(/^.*: /, ""); print; }'\
  | sort \
  | xargs)

  write_header "Processor" "$cpu"
}

#### Retrieve memory information  ####
# awk to extract 'Memory'
# awk to extract 'Type' & 'Speed'
# take top 2 lines
# sort so numeric comes first
# xargs to print to single line

# --> NEED TO UPDATE COMMENTS HERE <-- #

memory () { 

  local ram 
  ram=$(
  awk '
    $1~/Size/ && $2!~/Empty/ {size+=$2}
    $1~/Speed/ && $2!~/Empty/ {speed=$2" "$3}
    $1~/Type/ && $2!~/Empty/ {type=$2}
    END {print size " GB " speed " " type}
    ' <<< "$(system_profiler SPHardwareDataType; system_profiler SPMemoryDataType)"
)

  write_header "Memory" "${ram}"
}

#### Retrieve startup disk information  ####
# awk to extract third field
# sed to print string to the right of ':'
# awk to extract 'Mount Point'
# head to get primary drive

startup_disk () {

  local disk  
  disk=$(system_profiler SPStorageDataType \
  | awk 'FNR == 3 {print}'\
  | sed 's/[[:blank:]:]*//g')
  
  write_header "Startup Disk" "$disk" 
}

### Retrieve graphics information  ####
# awk to extract 'Model', 'Max', 'Total'
# xargs to print output to single line

graphics () {

  local gpu  
  gpu=$(system_profiler SPDisplaysDataType \
  | awk '/(Model|Max\)|Total\)):/ { sub(/^.*: /, ""); print; }' \
  | xargs)

  write_header "Graphics" "$gpu"
}

#### Retrieve serial number  ####
# awk to extract `Serial`

serial_number () {

  local serialnum
  serialnum=$(system_profiler SPHardwareDataType \
  | awk '/Serial/ { sub(/^.*: /, ""); print; }')

  write_header "Serial Number" "$serialnum"
}

#### Las entranas del programa ####

main () {

	osx_name
	operating_system
	hardware_model
	processor
	memory
	startup_disk
	graphics
	serial_number
}

main "$@"
