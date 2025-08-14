#!/bin/bash
# written by Max Chudnovsky
# a simple script that compares modules n different locally installed php versions

# exeptions for modules to ingore (for example, if some modules included in core php package)

# Define exceptions arrays for each PHP version
PHP8_1_EXCEPTIONS=(
        "Core" "date" "libxml" "openssl" "pcre" "zlib" "filter" "hash" "json" "pcntl" "random" \
        "Reflection" "SPL" "session" "standard" "sodium" "PDO" "calendar" "ctype" "exif" "FFI" \
        "fileinfo" "ftp" "gettext" "iconv" "Phar" "posix" "readline" "shmop" "sockets" \
        "sysvmsg" "sysvsem" "sysvshm" "tokenizer" "Zend OPcache"
)
PHP8_3_EXCEPTIONS=(
        "Core" "date" "libxml" "openssl" "pcre" "zlib" "filter" "hash" "json" "pcntl" "random" \
        "Reflection" "SPL" "session" "standard" "sodium" "PDO" "calendar" "ctype" "exif" "FFI" \
        "fileinfo" "ftp" "gettext" "iconv" "Phar" "posix" "readline" "shmop" "sockets" \
        "sysvmsg" "sysvsem" "sysvshm" "tokenizer" "Zend OPcache"
)
PHP8_4_EXCEPTIONS=(
        "Core" "date" "libxml" "openssl" "pcre" "zlib" "filter" "hash" "json" "pcntl" "random" \
        "Reflection" "SPL" "session" "standard" "sodium" "PDO" "calendar" "ctype" "exif" "FFI" \
        "fileinfo" "ftp" "gettext" "iconv" "Phar" "posix" "readline" "shmop" "sockets" \
        "sysvmsg" "sysvsem" "sysvshm" "tokenizer" "Zend OPcache"
)

# Function to get exceptions array for a given version
get_exceptions() {
        case "$1" in
                "8.1") echo "${PHP8_1_EXCEPTIONS[@]}" ;;
                "8.3") echo "${PHP8_3_EXCEPTIONS[@]}" ;;
                "8.4") echo "${PHP8_4_EXCEPTIONS[@]}" ;;
                *) echo "" ;;
        esac
}


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

# Get exceptions for each version
EXC1=( $(get_exceptions "$VER1") )
EXC2=( $(get_exceptions "$VER2") )

# Function to filter exceptions from module list
filter_exceptions() {
        local version="$1"
        shift
        local modules=("$@")
        local exceptions=( $(get_exceptions "$version") )
        for mod in "${modules[@]}"; do
                skip=0
                for exc in "${exceptions[@]}"; do
                        [[ "$mod" == "$exc" ]] && skip=1 && break
                done
                [[ $skip -eq 0 ]] && echo "$mod"
        done
}

# Get and filter modules for each version
MODS1=( $(php"${VER1}" -m | grep -v '\[' | sort -u) )
MODS2=( $(php"${VER2}" -m | grep -v '\[' | sort -u) )
FILT1=( $(filter_exceptions "$VER1" "${MODS1[@]}") )
FILT2=( $(filter_exceptions "$VER2" "${MODS2[@]}") )

# Compare filtered lists
OUT=$(diff <(printf "%s\n" "${FILT1[@]}") <(printf "%s\n" "${FILT2[@]}") | awk '/\</{print "Missing: "$2}/\>/{print "Extra: "$2}')

[ "$OUT" != "" ] && {
        echo -e "Comparing loaded modules for PHP${VER1} and PHP${VER2} (exceptions applied)\n\n$OUT"
} || {
        echo "No differences found."
}
