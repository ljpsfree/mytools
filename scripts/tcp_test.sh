#!/bin/bash

# Echo usage if something isn't right.
usage() {
    echo "Usage: $0 [-h <string>] [-p <80|443>] [-n <int>]" 1>&2; exit 1;
}

function cleanup()
{
    ratio=$(echo "scale=2; $SUCCESS_CNT/($SUCCESS_CNT+$FAIL_CNT)*100" | bc)
    echo $ratio
    echo "successful ratio: $ratio%"
    exit
}

trap cleanup SIGINT

while getopts ":h:p:n" o; do
    case "${o}" in
        h)
            HOST=${OPTARG}
            ;;
        p)
            PORT=${OPTARG}
            ;;
        n)
            NUMBER=${OPTARG}
            ;;
        :)
            echo "ERROR: Option -$OPTARG requires an argument"
            usage
            ;;
        \?)
            echo "ERROR: Invalid option -$OPTARG"
            usage
            ;;
    esac
done

[ -z "$HOST" ] && HOST="www.baidu.com"
[ -z "$NUMBER" ] && NUMBER=1000
[ -z "$PORT" ] && PORT=80

SUCCESS_CNT=0
FAIL_CNT=0
CNT=0

while [ $CNT -le $NUMBER ]
do
    date
    nc -zv -w 1 -G 1 $HOST $PORT
    result="$?"

    if [ "$result" -ne 0 ];
    then
        FAIL_CNT=$(( $FAIL_CNT + 1))
    else
        SUCCESS_CNT=$(( $SUCCESS_CNT + 1))
    fi

    CNT=$(( $CNT + 1 ))

    sleep 1
    echo ""
done
