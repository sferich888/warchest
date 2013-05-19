#!/bin/bash

function usage(){
    echo "USAGE: $0 LUKS_DEVICE MOUNT_POINT DICTIONARY_FILE"
    exit
} 

function smash(){
    $dictionary | while read i; do
        if echo "${i}" | cryptsetup luksOpen ${device} ${mount_point_name} -; then
           echo "********* ${i} *********** Success!"
           exit
        fi
     
        try=$(expr ${try} + 1)
        now_sec=$(date +%s)
     
        echo "try: ${try} of ${total}"
        average=$(echo "((${now_sec} - ${begin_sec}) / ${try})" | bc -l)
        eta=$(echo "((${total} - ${try}) * ${average}) + ${now_sec}" | bc | awk '{print int($1+0.5) }' )
        eta_date=$(echo $(date -d "1970-01-01 UTC ${eta} seconds"))
        echo "ESTIMATED COMPLETION: ${eta_date}"
        echo
    done
}

if [[ -n $1 ]]; then 
    device=$1
else
    usage
fi
if [[ -n $2 ]] && [[ -d $2 ]]; then 
    mount_point=$2
else
    usage
fi
if [[ -n $3 ]]; then 
    if [[ -d $3 ]]; then
        dictionary=$3
    else
        echo "Supplied Dictionary dose not exsit!"
        exit
    fi
else
    usage
fi

begin=$(date)
begin_sec=$(date +%s)
try=0
dictionary=/tmp/luks_dict
total=$(echo $dictionary | wc -w)

device=/dev/null
mount_point_name="device"

smash()
