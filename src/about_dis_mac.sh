#!/bin/bash
# mjk 2018.07.09

#=======================================================
#  CLI alternative to macOS's "About this Mac" feature.    
#  Retrieve information about: macOS "marketing" name;    
#  version number; hardware model; processor; memory; 
#  startup disk; graphics; and serial number.           
#=======================================================

#==========================================================
# This script frequently calls                            
# macOS's system_profiler to poll a data type, e.g.:       
# system_profiler SP_Some_DataType \                     
# | awk '/string_to_extract/{ sub(/^.*: /, ""); print; }')
# where the output of the profiler is piped to `awk`;     
# a search string is extracted;                           
# and characters to the right of `:` are printed          
#==========================================================

# Lookup table for macOS marketing names 

MARKETING_NAME=(
["10"]="Yosemite"
["11"]="El Capitan"
["12"]="Sierra"
["13"]="High Sierra"
["14"]="Mojave"
["15"]="Catalina"
)

# Display header message

write_header() {
  local name=$1; shift;
  printf "%s\\n""--------------------\\n$name%s\\n--------------------\\n"
  printf "%s\\n" "$@"
}

# Retrieve Apple's marketing name for installed operating system. 

macOS_name () {
  
  local macOS_number 
  macOS_number=$(sw_vers -productVersion| awk -F '[.]' '{print $2}')
 
  if [[ -n "${MARKETING_NAME[$macOS_number]}" ]]; then 
    local macOS_name
    macOS_name="${MARKETING_NAME[$macOS_number]}"    
fi
  
  write_header "macOS" "$macOS_name"
}

# Retrieve operating system version 

operating_system () {

  local os  
  os=$(sw_vers -productVersion)

  write_header "Version" "$os"
}

# Retrieve hardware model 

hardware_model () { 
 
  local hardware_mod
  hardware_mod=$(defaults read /Users/$LOGNAME/Library/Preferences/com.apple.SystemProfiler.plist \
  'CPU Names' | cut -sd '"' -f 4 | uniq) 
    
  write_header "Hardware Model" "$hardware_mod"
} 

# Retrieve processor information 

processor () {

  local cpu  
  cpu=$(system_profiler SPHardwareDataType \
  | awk '/Processor (Name|Speed):/ { sub(/^.*: /, ""); print; }'\
  | sort \
  | xargs)

  write_header "Processor" "$cpu"
}

# Retrieve memory information 

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

# Retrieve startup disk information

startup_disk () {

  local disk  
  disk=$(system_profiler SPStorageDataType \
  | awk 'FNR == 3 {print}'\
  | sed 's/[[:blank:]:]*//g')
  
  write_header "Startup Disk" "$disk" 
}

# Retrieve graphics information

graphics () {

  local gpu  
  gpu=$(system_profiler SPDisplaysDataType \
  | awk '/(Model|Max\)|Total\)):/ { sub(/^.*: /, ""); print; }' \
  | xargs)

  write_header "Graphics" "$gpu"
}

# Retrieve serial number

serial_number () {

  local serialnum
  serialnum=$(system_profiler SPHardwareDataType \
  | awk '/Serial/ { sub(/^.*: /, ""); print; }')

  write_header "Serial Number" "$serialnum"
}

# Las entranas del programa 

main () {

	macOS_name
	operating_system
	hardware_model
	processor
	memory
	startup_disk
	graphics
	serial_number
}

main "$@"
