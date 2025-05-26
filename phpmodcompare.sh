#!/bin/bash
# written by Max Chudnovsky
# a simple script that compares modules n different locally installed php versions

# init (parameters will accept only numeric and .)
VER1=$(echo "$1" | sed 's/[^0-9.]//g')
VER2=$(echo "$2" | sed 's/[^0-9.]//g')

# function checks if version of php is installed
chkphp(){
  OUT=$(dpkg -l php"$1" 2>&1 | grep ^ii) || {
    echo "$0: Error: PHP$1 is not installed"
    exit 1
  }
}

# check if parameters were provided correctly
[ $# != 2 ] && {
        echo "$0: Error: wrong number of parameters."
        echo "  Usage Example: $0 8.1 8.4"
        echo -e "\n  detected versions: $(dpkg -l php*-common | awk '/^ii/||/!php-common/{print $2}'| sed -e 's/-common//' -e 's/php//' | xargs)"
        exit 1
} || {
        # and if we got correct number then lets verify those php versions are valid and installed
        chkphp $VER1
        chkphp $VER2
}

# main logic
OUT=`diff <(php"${VER1}" -m | grep -v '\[' | sort -u) <(php"${VER2}" -m | grep -v '\[' | sort -u) | awk '/\</{print "Missing: "$2}/\>/{print "Extra: "$2}'`

[ "$OUT" != "" ] && {
        echo -e "Comparing loaded modules for PHP${VER1} and PHP${VER2}\n\n$OUT"
} || {
        echo "No differences found."
}
