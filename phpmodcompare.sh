#!/bin/bash
# written by Max Chudnovsky

# init
VER1="$1"
VER2="$2"

# function checks if version of php is installed
chkphp(){
  OUT=$(dpkg -l php"$1" 2>&1 | grep ^ii) || {
    echo "$0: Error: PHP$1 is not installed"
    exit 1
  }
}

[ $# != 2 ] && {
        # lets make sure we got correct number of parameters
        echo "$0: Error: wrong number of parameters."
        echo "  Usage Example: $0 8.1 8.4"
        echo -e "\n  detected versions: $(dpkg -l php*-common | awk '/^ii/||/!php-common/{print $2}'| sed -e 's/-common//' -e 's/php//' | xargs)"
        exit 1
} || {
        # lets verify those php versions are valid and installed
        chkphp $VER1
        chkphp $VER2
}

# main
echo "Comparing loaded modules for PHP${VER1} and PHP${VER2}"
diff <(php"${VER1}" -m | grep -v '\[' | sort -u) <(php"${VER2}" -m | grep -v '\[' | sort -u) | awk '/\</{print "Missing: "$2}/\>/{print "Extra: "$2}'
