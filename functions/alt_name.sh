#!/usr/bin/env bash

# Extract macOS software version number 
# then lookup number in array and display marketing number.

macOS_number=$(sw_vers -productVersion | awk -F '[.]' '{print $1}')

printf "%s\\n" "$macOS_number"

# Lookup table

MACOS_MARKETING_NAME=(
["10"]="Yosemite"
["11"]="El Capitan"
["12"]="Sierra"
["13"]="High Sierra"
["14"]="Mojave"
["15"]="Catalina"
["2"]="Big Sur"
)

macOS_name () {

  if [[ -n "${MACOS_MARKETING_NAME[$macOS_number]}" ]]; then
    printf "%s\\n" "${MACOS_MARKETING_NAME[$macOS_number]}"
fi
}

macOS_name
