#!/bin/bash
# written by Max Chudnovsky
# a simple script that compares modules n different locally installed php versions

# exeptions for modules to ingore (for example, if some modules included in core php package)


# Function to get core modules for a given PHP version
get_core_modules() {
        # shellcheck disable=SC2154
        php"$1" -r "foreach(get_loaded_extensions() as \$m) echo \"$m\\n\";" | sort -u
}


# init (parameters will accept only numeric and .)
VER1="${1//[^0-9.]/}"
VER2="${2//[^0-9.]/}"

# function checks if version of php is installed
chkphp(){
  OUT=$(dpkg -l php"$1" 2>&1 | grep ^ii) || {
    echo "$0: Error: PHP$1 is not installed"
    exit 1
  }
}

# check if parameters were provided correctly
if [ "$#" -ne 2 ]; then
        echo "$0: Error: wrong number of parameters."
        echo "  Usage Example: $0 8.1 8.4"
        echo -e "\n  detected versions: $(dpkg -l php*-common | awk '/^ii/||/!php-common/{print $2}'| sed -e 's/-common//' -e 's/php//' | xargs)"
        exit 1
else
        # and if we got correct number then lets verify those php versions are valid and installed
        chkphp "$VER1"
        chkphp "$VER2"
fi

# main logic


# Get installed modules for each version
mapfile -t INST1 < <(php"${VER1}" -m | grep -v '\[' | sort -u)
mapfile -t INST2 < <(php"${VER2}" -m | grep -v '\[' | sort -u)

# Get core modules for each version
mapfile -t CORE1 < <(get_core_modules "$VER1")
mapfile -t CORE2 < <(get_core_modules "$VER2")

# Combine installed and core modules, then sort and uniq
mapfile -t ALL1 < <(printf "%s\n" "${INST1[@]}" "${CORE1[@]}" | sort -u)
mapfile -t ALL2 < <(printf "%s\n" "${INST2[@]}" "${CORE2[@]}" | sort -u)

# Compare combined lists
OUT=$(diff <(printf "%s\n" "${ALL1[@]}") <(printf "%s\n" "${ALL2[@]}") | awk '/\</{print "Missing: "$2}/\>/{print "Extra: "$2}')

if [ "$OUT" != "" ]; then
        echo -e "Comparing loaded modules for PHP${VER1} and PHP${VER2} (core modules included automatically)\n\n$OUT"
else
        echo "No differences found."
fi
