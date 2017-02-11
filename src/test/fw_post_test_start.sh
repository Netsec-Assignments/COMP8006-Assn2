doPacketCountTest()
{
    CHAIN=$1
    RULE_NUM=$2
    EXPECTED=$3
    ACTUAL=$4

    if [ $ACTUAL -ge $EXPECTED ]; then
        echo "$CHAIN rule $RULE_NUM PASSED with expected packet count of at least $EXPECTED."
    else
        echo "$CHAIN rule $RULE_NUM FAILED: had packet count $ACTUAL, should have been at least $EXPECTED."
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

# Check the drop-invalid chain's results before user-defined
getRuleResults "$(iptables -vnL drop-invalid)"
DROP_INVALID_RESULTS=("${RESULT[@]}")
EXPECTED_INVALID_RESULTS=()
EXPECTED_INVALID_RESULTS[0]=0   # -p tcp --tcp-flags ALL ACK,RST,SYN,FIN -j DROP
EXPECTED_INVALID_RESULTS[1]=5   # -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
EXPECTED_INVALID_RESULTS[2]=0   # -p tcp --tcp-flags SYN,FIN,PSH SYN,FIN,PSH -j DROP
EXPECTED_INVALID_RESULTS[3]=0   # -p tcp --tcp-flags ALL ALL -j DROP
EXPECTED_INVALID_RESULTS[4]=0   # -p tcp --tcp-flags ALL NONE -j DROP
EXPECTED_INVALID_RESULTS[5]=5   # -p tcp --sport 23 -j DROP
EXPECTED_INVALID_RESULTS[6]=5   # -p tcp --dport 23 -j DROP
EXPECTED_INVALID_RESULTS[7]=40  # -i $EXTERNAL_DEVICE -p tcp -m multiport --dports 32768:32775 -j DROP
EXPECTED_INVALID_RESULTS[8]=40  # -i $EXTERNAL_DEVICE -p udp -m multiport --dports 32768:32775 -j DROP
EXPECTED_INVALID_RESULTS[9]=15  # -i $EXTERNAL_DEVICE -p tcp -m multiport --dports 137:139 -j DROP
EXPECTED_INVALID_RESULTS[10]=15 # -i $EXTERNAL_DEVICE -p udp -m multiport --dports 137:139 -j DROP
EXPECTED_INVALID_RESULTS[11]=10 # -i $EXTERNAL_DEVICE -p tcp -m multiport --dports 111,515 -j DROP

for (( i=0; i<${#EXPECTED_INVALID_RESULTS[@]}; i++ )) do
    echo "Checking packet counts for drop-invalid rule $i."
    echo "                 pkts bytes target     prot opt in     out     source               destination"
    echo "drop-invalid rule \$i:  \${DROP_INVALID_RESULTS[i]}"

    getPacketCount "${DROP_INVALID_RESULTS[i]}"
    doPacketCountTest drop-invalid $i ${EXPECTED_INVALID_RESULTS[i]} $COUNT
done

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

