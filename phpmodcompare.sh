#!/bin/bash
# Script compares installed mods of 2 versions of php installed on the same servers and reports differences
# written by Max Chudnovsky

# init
VER1="${1//[!0-9.]/}"
VER2="${2//[!0-9.]/}"

# function checks if version of php is installed
chkphp(){
  OUT=$(dpkg -l php"$1" 2>&1 | grep ^ii) || {
    echo "$0: Error: PHP$1 is not installed"
    exit 1
  }
}

if [ $# != 2 ] && [ $# != 0 ]; then
        # lets make sure we got correct number of parameters
        echo "$0: Error: wrong number of parameters."
        echo "  Usage Example: $0 8.1 8.4"
        exit 1
elif [ $# == 0 ]; then
	echo "Detected those PHP versions:"
	dpkg -l | grep php  | grep ^ii | awk '/metapackage/{print $2}'
	exit 0
else
        # lets verify those php versions are valid and installed
        chkphp $VER1
        chkphp $VER2
fi

# main
echo "Comparing loaded modules for PHP${VER1} and PHP${VER2}"
diff <(php"${VER1}" -m | grep -v '\[' | sort -u) <(php"${VER2}" -m | grep -v '\[' | sort -u) | awk '/\</{print "Missing: "$2}/\>/{print "Extra: "$2}'
