#set -x

###################################################################################################
# Name: 
#  Assignment_2_Firewall.sh
# Description:
#  This application creates a personal firewall for Assignment 2 of Comp 8006.
#
# The firewall has the following rules:
#	Get user specified parameters (see constraints) and create a set of rules that will implement
#	the firewall requirements. Specifically the firewall will control:
#	Inbound/Outbound TCP packets on allowed ports.
#	Inbound/Outbound UDP packets on allowed ports.
#	Inbound/Outbound ICMP packets based on type numbers.
#	All packets that fall through to the default rule will be dropped.
#	Drop all packets destined for the firewall host from the outside.
#	Do not accept any packets with a source address from the outside matching your internal network.
#	You must ensure the you reject those connections that are coming the “wrong” way (i.e., inbound 
#	SYN packets to high ports).
#	Accept fragments.
#	Accept all TCP packets that belong to an existing connection (on allowed ports).
#	Drop all TCP packets with the SYN and FIN bit set.
#	Do not allow Telnet packets at all.
#	Block all external traffic directed to ports 32768 – 32775, 137 – 139, TCP ports 111 and 515.
#	For FTP and SSH services, set control connections to "Minimum Delay" and FTP data to "Maximum Throughput".
#
# The Firewall has the following constraints:
#	The user configuration section will allow a user to set at least the following parameters:
#		Name and location of the utility you are using to implement the firewall.
#		Internal network address space and the network device.
#		Outside address space and the network device.
#		TCP services that will be allowed.
#		UDP services that will be allowed.
#		ICMP services that will be allowed.
#	Only allow NEW and ESTABLISHED - Stateful filtering
#	You must ensure that you reject those connections that are coming the "wrong" way,
#	meaning inbound connection requests (unless of course it is to a permitted service).
#
###################################################################################################

#!/bin/bash

# TOS: PPPDTRC0 (P = Precedence, D = Delay, T = Throughput, R = Reliability, C = Cost ($), 0 = Reserved

MINIMUM_DELAY=8
MAXIMUM_GOODPUT=4


###################################################################################################
# Name: 
#  splitServices
# Description:
#  Split a semicolon-separated list of services into an array (store in the first argument).
###################################################################################################
splitServices()
{
    RESULT=()
    IFS=';' read -ra SPLIT_LIST <<< "$1"
    for i in "${SPLIT_LIST[@]}"; do
        RESULT+=("$i")
    done
}

###################################################################################################
# Name: 
#  deleteFilters
# Description:
#  This function flushes the filters and deletes the user chains.
###################################################################################################
deleteFilters()
{
	echo
	echo 'Flushing the filters'
	iptables -F INPUT
	iptables -F OUTPUT
	iptables -F FORWARD
	iptables --flush	
	echo 'Deleting user chains'
	iptables -X
}

###################################################################################################
# Name: 
#  resetFilters
# Description:
#  This function sets the default policy on the firewall to ALLOW.
###################################################################################################
resetFilters()
{
	echo 'Setting default policy to ALLOW for firewall'
	iptables -P FORWARD ACCEPT
}

###################################################################################################
# Name: 
#  setDefaultToDrop
# Description:
#  This function sets the default policy on the firewall to DROP.
###################################################################################################
setDefaultToDrop()
{
	echo 'Setting default policy to DROP for firewall'
	iptables -P FORWARD DROP
}

###################################################################################################
# Name: 
#  dropPortZeroTraffic
# Description:
#  This function drops all incoming packets and inbound traffic from port 0
###################################################################################################
dropPortZeroTraffic()
{
	echo 'Drop all incoming packets and inbound traffic from port 0'
	iptables -A INPUT -f -j DROP
	iptables -A INPUT -p tcp --dport 0 -j DROP
	iptables -A INPUT -p tcp --sport 0 -j DROP
}

###################################################################################################
# Name: 
#  inOutboundTCP
# Description:
#  This function sets the TCP rules for outbound connections.
###################################################################################################
inOutboundTCP()
{
    echo 'Setting TCP rules'
    for i in "${TCP_SERVICES[@]}"; do
        iptables -A FORWARD -d $INTERNALADDRESS -i $EXTERNALDEVICE -p tcp $i
    done
}



###################################################################################################
# Name: 
#  allowDNSAndDHCPTraffic
# Description:H
#  This function drops inbound traffic to port 80 (http) from source ports less than 1024.
###################################################################################################
allowDNSAndDHCPTraffic()
{
	echo 'Allow DNS and DHCP Traffic'
	iptables -A INPUT -p udp --sport 53 -j other-in
	iptables -A OUTPUT -p udp --dport 53 -j other-out
	iptables -A INPUT -p udp --sport 67:68 --dport 67:68 -j other-in
	iptables -A OUTPUT -p udp --dport 67:68 --sport 67:68 -j other-out
}

###################################################################################################
# Name: 
#  createDropTrafficRules
# Description:
#  This function drops invalid TCP Packets that are inbound
###################################################################################################
createDropTrafficRules()
{
    iptables -A INPUT -j DROP

	echo 'Drop invalid TCP Packets that are inbound'
	iptables -A FORWARD -p tcp --tcp-flags ALL ACK,RST,SYN,FIN -j DROP
	iptables -A FORWARD -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
	iptables -A FORWARD -p tcp --tcp-flags SYN,FIN,PSH SYN,FIN,PSH -j DROP
	iptables -A FORWARD -p tcp --tcp-flags ALL ALL -j DROP
	iptables -A FORWARD -p tcp --tcp-flags ALL NONE -j DROP

	echo 'Drop telnet in and out'
	iptables -A FORWARD -p tcp --sport 23 -j DROP	
	iptables -A FORWARD -p tcp --dport 23 -j DROP	

	echo 'Drop traffic to 32768-32775'
	iptables -A FORWARD -i $EXTERNAL_DEVICE -p tcp -m multiport --dports 32768:32775 -j DROP
	iptables -A FORWARD -i $EXTERNAL_DEVICE -p udp -m multiport --dports 32768:32775 -j DROP

	echo 'Drop traffic to 137-139'
	iptables -A FORWARD -i $EXTERNAL_DEVICE -p tcp -m multiport --dports 137:139 -j DROP
	iptables -A FORWARD -i $EXTERNAL_DEVICE -p udp -m multiport --dports 137:139 -j DROP

	echo 'Drop traffic to 111 & 515'
	iptables -A FORWARD -i $EXTERNAL_DEVICE -p tcp -m multiport --dports 111,515 -j DROP

	#echo 'Drop all network activity that appears to be from the internal network'
	#iptables -A FORWARD -i $EXTERNAL_DEVICE -d $INTERNAL_ADDRESS_SPACE -j DROP

	echo 'Drop any SYN targeting high port coming the wrong way'
	iptables -A FORWARD -p tcp --syn -m multiport --dports 1025:65535 -j DROP

	#echo 'Drop service to service traffic.'
	#iptables -A FORWARD -p tcp --sport 0:1024 --dport 0:1024 -j DROP
	#iptables -A FORWARD -p udp --sport 0:1024 --dport 0:1024 -j DROP

}

###################################################################################################
# Name: 
#  createFirewallRules
# Description:
#  This function creates the firewall rules.
###################################################################################################
createFirewallRules()
{
    iptables -P FORWARD DROP

    # Allow DNS traffic
    iptables -A FORWARD -i $INTERNAL_DEVICE -p tcp --dport domain -j ACCEPT
    iptables -A FORWARD -o $INTERNAL_DEVICE -p tcp --sport domain -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    iptables -A FORWARD -i $INTERNAL_DEVICE -p udp --dport domain -j ACCEPT
    iptables -A FORWARD -o $INTERNAL_DEVICE -p udp --sport domain -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 

    # Set up chains for accounting and testing
    iptables -N tcp-in
    iptables -N tcp-out
    iptables -A FORWARD -p tcp -i $EXTERNAL_DEVICE -o $INTERNAL_DEVICE -j tcp-in
    iptables -A FORWARD -p tcp -i $INTERNAL_DEVICE -o $EXTERNAL_DEVICE -j tcp-out

    iptables -N udp-in
    iptables -N udp-out
    iptables -A FORWARD -p udp -i $EXTERNAL_DEVICE -o $INTERNAL_DEVICE -j udp-in
    iptables -A FORWARD -p udp -i $INTERNAL_DEVICE -o $EXTERNAL_DEVICE -j udp-out

    iptables -N icmp-in
    iptables -N icmp-out
    iptables -A FORWARD -p icmp -i $EXTERNAL_DEVICE -o $INTERNAL_DEVICE -j icmp-in
    iptables -A FORWARD -p icmp -i $INTERNAL_DEVICE -o $EXTERNAL_DEVICE -j icmp-out   

    for i in "${TCP_SVC_IN[@]}"; do
        echo "Adding rule for TCP INBOUND service: $i"
        # Set up port forwarding, allow inbound connections on given ports, and allow outbound traffic from the server
        iptables -t nat -A PREROUTING -i $EXTERNAL_DEVICE -p tcp --dport $i --tcp-flags ALL SYN -j DNAT --to-destination $INTERNAL_STATIC_IP
        iptables -A tcp-in -d $INTERNAL_STATIC_IP -p tcp --dport $i -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
        iptables -A tcp-out -s $INTERNAL_STATIC_IP -p tcp --sport $i -j ACCEPT
    done

    for i in "${TCP_SVC_OUT[@]}"; do
        echo "Adding rule for TCP OUTBOUND service: $i"
        iptables -A tcp-in -p tcp --sport $i -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
        iptables -A tcp-out -p tcp --dport $i -j ACCEPT
    done

	#drop TCP rules not declared by user.
    #iptables -A tcp -j DROP

    for i in "${UDP_SVC_IN[@]}"; do
        echo "Adding rule for UDP INBOUND service: $i"
        iptables -t nat -A PREROUTING -p udp -i $EXTERNAL_DEVICE --dport $i -j DNAT --to-destination $INTERNAL_STATIC_IP:$i
        iptables -A udp-in -p udp --dport $i -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
        iptables -A udp-out -p udp --sport $i -j ACCEPT
    done

    for i in "${UDP_SVC_OUT[@]}"; do
        echo "Adding rule for UDP OUTBOUND service: $i"
        iptables -A udp-in -p udp --sport $i -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
        iptables -A udp-out -p udp --dport $i -j ACCEPT
    done

	#drop UDP rules not declared by user.
	#iptables -A udp -j DROP

    for i in "${ICMP_SVC_IN[@]}"; do
        echo "Adding rule for ICMP INBOUND type: $i"
        iptables -A icmp-in -p icmp --icmp-type $i -j ACCEPT
    done

    for i in "${ICMP_SVC_OUT[@]}"; do
        echo "Adding rule for ICMP OUTBOUND type: $i"
        iptables -A icmp-out -p icmp --icmp-type $i -j ACCEPT
    done

	#drop ICMP rules not declared by user.
    #iptables -A icmp -j DROP
}

###################################################################################################
# Name: 
#  createFirewallRules
# Description:
#  This function setups the routing.
###################################################################################################
setupRouting()
{
	echo 'Setting up the firewall machine'

    ethtool -s $INTERNAL_DEVICE mdix on

    ip link set $INTERNAL_DEVICE up
    ip addr add $INTERNAL_GATEWAY_IP_MASKED dev $INTERNAL_DEVICE

    echo "1" >/proc/sys/net/ipv4/ip_forward
}

###################################################################################################
# Name: 
#  resetRouting
# Description:
#  This function resets the routing.
###################################################################################################
resetRouting()
{
    ethtool -s $INTERNAL_DEVICE mdix auto

    echo "0" >/proc/sys/net/ipv4/ip_forward
    
    ip route delete $EXTERNAL_ADDRESS_SPACE via $EXTERNAL_GATEWAY_IP dev $EXTERNAL_DEVICE
    ip route delete $INTERNAL_ADDRESS_SPACE via $INTERNAL_GATEWAY_IP dev $INTERNAL_DEVICE

    ip addr delete $INTERNAL_GATEWAY_IP_MASKED dev $INTERNAL_DEVICE
    ip link set $INTERNAL_DEVICE down
}

###################################################################################################
# Name: 
#  setupMangle
# Description:
#  This function setups the mangle tables.
###################################################################################################
setupMangle()
{
	echo 'Setting up the mangle table'

	iptables -t mangle -A PREROUTING -p tcp --dport ssh -j TOS --set-tos $MINIMUM_DELAY
	iptables -t mangle -A PREROUTING -p tcp --sport ssh -j TOS --set-tos $MINIMUM_DELAY

    iptables -t mangle -A PREROUTING -p tcp --dport ftp -j TOS --set-tos $MAXIMUM_GOODPUT
	iptables -t mangle -A PREROUTING -p tcp --sport ftp -j TOS --set-tos $MAXIMUM_GOODPUT
}


splitServices $TCP_SVC_IN
TCP_SVC_IN=(${RESULT[@]})
splitServices $TCP_SVC_OUT
TCP_SVC_OUT=(${RESULT[@]})

splitServices $UDP_SVC_IN
UDP_SVC_IN=(${RESULT[@]})
splitServices $UDP_SVC_OUT
UDP_SVC_OUT=(${RESULT[@]})

splitServices $ICMP_SVC_IN
ICMP_SVC_IN=(${RESULT[@]})
splitServices $ICMP_SVC_OUT
ICMP_SVC_OUT=(${RESULT[@]})

#resetRouting
#setupRouting

deleteFilters
resetFilters
setupMangle
setDefaultToDrop
dropPortZeroTraffic
createDropTrafficRules			
createFirewallRules

