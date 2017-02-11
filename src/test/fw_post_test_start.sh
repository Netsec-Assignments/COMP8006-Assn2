doPacketCountTest()
{
    CHAIN=$1
    RULE_NUM=$2
    EXPECTED=$3
    ACTUAL=$4

    if [ $ACTUAL == $EXPECTED ]; then
        echo "$CHAIN rule $RULE_NUM PASSED with expected packet count $EXPECTED."
    else
        echo "$CHAIN rule $RULE_NUM FAILED: had packet count $ACTUAL, should have been $EXPECTED."
    fi
}

getRuleResults()
{
    RESULT=()
    while read LINE; do
        #echo $LINE
        RESULT+=("$LINE")
    done <<< "$1"

    RESULT=("${RESULT[@]:2}")
}

getPacketCount()
{
    COUNT=$(echo "$1" | awk '{print $1}')
}

getRuleResults "$(iptables -vnL tcp-in)"
TCP_IN_RESULTS=("${RESULT[@]}")
getRuleResults "$(iptables -vnL tcp-out)"
TCP_OUT_RESULTS=("${RESULT[@]}")

getRuleResults "$(iptables -vnL udp-in)"
UDP_IN_RESULTS=("${RESULT[@]}")
getRuleResults "$(iptables -vnL udp-out)"
UDP_OUT_RESULTS=("${RESULT[@]}")

getRuleResults "$(iptables -vnL icmp-in)"
ICMP_IN_RESULTS=("${RESULT[@]}")
getRuleResults "$(iptables -vnL icmp-out)"
ICMP_OUT_RESULTS=("${RESULT[@]}")

