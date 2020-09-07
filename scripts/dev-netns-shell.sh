#!/bin/bash

ns=""

while getopts h-: option; do
    case "${option}" in
        -)
            case "${OPTARG}" in
                ns)
                    val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ns=$val
                    ;;
                ns=*)
                    val=${OPTARG#*=}
                    ns=$val
                    ;;
                *)
                    if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                        echo "Unknown option --${OPTARG}" >&2
                    fi
                    ;;
            esac;;
        h)
            echo $(basename $0): usage: $(basename $0) [-h] [--ns=name] [dev] [dev]
            exit 0
            ;;
    esac
done
shift $((OPTIND -1))

dev=$1

if [ -z "$ns" ]; then
    if [ -z "$dev" ]; then
        echo "Error: must specify either device or network namespace name"
        exit 1
    fi

    ns=$dev
fi

if [ -f "/var/run/netns/$ns" ]; then
    echo "Network namespace '$ns' already exists"
else
    echo "Creating network namespace '$ns'"
    ip netns add $ns
    for d in "$@"
    do
        echo "Adding interface '$d' to network namespace '$ns'"
        ip link set dev $d netns $ns
        ip netns exec $ns ip link set dev $d up
    done
fi

if [ -f "/var/run/netns/$ns" ]; then
    echo "Starting shell in network namespace '$ns'"
    echo "Note: \$dev='$dev'"
    export dev
    ip netns exec $ns bash
else
    echo "Error: network namespace not found"
fi

if [ -f "/var/run/netns/$ns" -a -z "$(ip netns pids $ns)" ]; then
    echo "Deleting network namespace '$ns'"
    ip netns del $ns
fi

