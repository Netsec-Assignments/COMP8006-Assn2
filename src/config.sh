###################################################################################################
# File: 
#  lab4.sh
# Developers
#  Mat Siwoski
#  Shane Spoor
# Date created:
#  10/22/2016
# Description:
#  To design and implement a shell script that will implement a
#  cron-based email notification application. 
###################################################################################################

#!/bin/bash

#DEFAULT VALUES
FIREWALL_PATH=""

# Service configuration
TCP_SVC_OUT=""
TCP_SVC_IN=""

UDP_SVC_OUT=""
UDP_SVC_IN=""

ICMP_SVC_OUT=""
ICMP_SVC_IN=""

INTERNAL_ADDRESS_SPACE=""
INTERNAL_DEVICE=""
EXTERNAL_ADDRESS_SPACE=""
EXTERNAL_DEVICE=""

INTERNAL_GATEWAY_IP_MASKED=""
INTERNAL_STATIC_IP_MASKED=''
EXTERNAL_GATEWAY_IP_MASKED=""

INTERNAL_GATEWAY_IP=""
INTERNAL_STATIC_IP=''
EXTERNAL_GATEWAY_IP=""

TEST_ADDR=""

###################################################################################################
# Name: 
#  continueApplication
# Description:
#  This function deals with pressing the Enter button after buttons have been pressed.
###################################################################################################
continueApplication()
{
    echo
    echo -n ' Press Enter to continue.....'
    read rest
}

###################################################################################################
# Name: 
#  configureFirewallLocation
# Description:
#  This function sets the path of the firewall.
###################################################################################################
configureFirewallLocation()
{
    echo 'Enter path to the firewall:'
    read fw_path rest
    FIREWALL_PATH=${fw_path}
    if ! [ -f ${FIREWALL_PATH} ]; then
        echo "No such file or directory ${fw_path}. Please enter a new location."
    fi
}

###################################################################################################
# Name: 
#  configureInternalAddressSpaceAndDevice
# Description:
#  This function configures the internal address space and device.
###################################################################################################
configureInternalAddressSpaceAndDevice()
{
    echo 'Enter the internal network address space'
    read addr_space rest
    INTERNAL_ADDRESS_SPACE=${addr_space}
    if [ -z ${INTERNAL_ADDRESS_SPACE} ]; then
        echo "Please enter a valid address space."
    fi
    
    echo 'Enter the internal network device'
    read device_name rest
    INTERNAL_DEVICE=${device_name}
    if [ -z ${INTERNAL_DEVICE} ]; then
        echo "Please enter a valid device."
    fi
}

###################################################################################################
# Name: 
#  configureExternalAddressSpaceAndDevice
# Description:
#  This function configures the external address space and device.
###################################################################################################
configureExternalAddressSpaceAndDevice()
{
    echo 'Enter the external network address space'
    read addr_space rest
    EXTERNAL_ADDRESS_SPACE=${addr_space}
    if [ -z ${EXTERNAL_ADDRESS_SPACE} ]; then
        echo "Please enter a valid address space."
    fi
    
    echo 'Enter the external network device'
    read device_name rest
    EXTERNAL_DEVICE=${device_name}
    if [ -z ${EXTERNAL_DEVICE} ]; then
        echo "Please enter a valid device."
    fi
}

###################################################################################################
# Name: 
#  configureTCPServices
# Description:
#  This function configures the TCP services.
###################################################################################################
configureTCPServices()
{
    echo 'Enter a semicolon-separated list of allowed OUTBOUND TCP services.'
    read LIST REST
    IFS=';' read -ra SPLIT_LIST <<< "$LIST"
    for i in "${SPLIT_LIST[@]}"; do
        SERVICE=`getent services $i/tcp`
        if [ -z "$SERVICE" ]; then
            echo "No such service $i for TCP. Please enter a valid service name or port number."
        else
            TCP_SVC_OUT+="$i;"
            echo "TCP service $SERVICE added to allowed outbound traffic."
        fi
    done

    echo 'Enter a semicolon-separated list of allowed INBOUND TCP services.'
    read LIST REST
    IFS=';' read -ra SPLIT_LIST <<< "$LIST"
    for i in "${SPLIT_LIST[@]}"; do
        SERVICE=`getent services $i/tcp`
        if [ -z "$SERVICE" ]; then
            echo "No such service $i for TCP. Please enter a valid service name or port number."
        else
            TCP_SVC_IN+="$i;"
            echo "TCP service $SERVICE added to allowed inbound traffic."
        fi
    done
}

###################################################################################################
# Name: 
#  configureUDPServices
# Description:
#  This function configures the UDP services.
###################################################################################################
configureUDPServices()
{
    echo 'Enter a semicolon-separated list of allowed UDP services.'
    read LIST REST
    IFS=';' read -ra SPLIT_LIST <<< "$LIST"
    for i in "${SPLIT_LIST[@]}"; do
        SERVICE=`getent services $i/udp`
        if [ -z "$SERVICE" ]; then
            echo "No such service $i for UDP. Please enter a valid service name or port number."
        else
            UDP_SVC_OUT+="$i;"
            echo "UDP service $SERVICE added to allowed outbound traffic."
        fi
    done

    echo 'Enter a semicolon-separated list of allowed INBOUND UDP services.'
    read LIST REST
    IFS=';' read -ra SPLIT_LIST <<< "$LIST"
    for i in "${SPLIT_LIST[@]}"; do
        SERVICE=`getent services $i/udp`
        if [ -z "$SERVICE" ]; then
            echo "No such service $i for UDP. Please enter a valid service name or port number."
        else
            UDP_SVC_IN+="$i;"
            echo "UDP service $SERVICE added to allowed inbound traffic."
        fi
    done
}

###################################################################################################
# Name: 
#  configureICMPServices
# Description:
#  This function configures the ICMP services.
###################################################################################################
configureICMPServices()
{
    echo 'Enter a semicolon-separated list of allowed OUTBOUND ICMP services (by type; see below).'
    echo '
    Type    Name                    
    ----    -------------------------
      0        Echo Reply                 
      1        Unassigned                 
      2        Unassigned                 
      3        Destination Unreachable    
      4        Source Quench            
      5        Redirect                
      6        Alternate Host Address    
      7        Unassigned                
      8        Echo                    
      9        Router Advertisement    
     10        Router Selection        
     11        Time Exceeded            
     12        Parameter Problem        
     13        Timestamp                
     14        Timestamp Reply            
     15        Information Request        
     16        Information Reply        
     17        Address Mask Request    
     18        Address Mask Reply        
     19        Reserved (for Security)    
     20-29  Reserved (for Robustness Experiment)        
     30     Traceroute
     31     Datagram Conversion Error
     32     Mobile Host Redirect 
     33     IPv6 Where-Are-You   
     34     IPv6 I-Am-Here       
     35     Mobile Registration Request
     36     Mobile Registration Reply  
     37     Domain Name Request        
     38     Domain Name Reply          
     39     SKIP                       
     40     Photuris
     41-255 Reserved'
     
    read LIST REST
    IFS=';' read -ra SPLIT_LIST <<< "$LIST"
    for i in "${SPLIT_LIST[@]}"; do
        if [ "$i" -lt 0 ] || [ "$i" -gt 255 ]; then
            echo "$i is not valid ICMP type. Type must be between 0 and 255 (inclusive)."
        else
            ICMP_SVC_OUT+="$i;"
            echo "Type $i added to allowed outbound traffic."
        fi        
    done

    echo 'Enter a semicolon-separated list of allowed INBOUND ICMP services (by type; see above).'
    read LIST REST
    IFS=';' read -ra SPLIT_LIST <<< "$LIST"
    for i in "${SPLIT_LIST[@]}"; do
        if [ "$i" -lt 0 ] || [ "$i" -gt 255 ]; then
            echo "$i is not valid ICMP type. Type must be between 0 and 255 (inclusive)."
        else
            ICMP_SVC_INT+="$i;"
            echo "Type $i added to allowed inbound traffic."
        fi        
    done
}


###################################################################################################
# Name: 
#  getServicePort
# Description:
#  This function gets the service port.
###################################################################################################
getServicePort()
{
    SERVICE=$1
    PROTOCOL=$2
    
    RESOLVED=$(getent services $SERVICE/$PROTOCOL)
    if [ -z ${RESOLVED+x} ]; then
        echo "No service is mapped to $SERVICE for protocol $PROTOCOL."
        RESOLVED=$1
    else
        RESOLVED=$(echo $RESOLVED | awk '{print $2}' | cut -d'/' -f 1)    
    fi
}

###################################################################################################
# Name: 
#  exportConfig
# Description:
#  Exports the configuration variables for use by sub-shells.
###################################################################################################
exportConfig()
{
    export INTERNAL_ADDRESS_SPACE
    export EXTERNAL_ADDRESS_SPACE
    export INTERNAL_DEVICE
    export EXTERNAL_DEVICE
    export INTERNAL_GATEWAY_IP_MASKED
    export EXTERNAL_GATEWAY_IP_MASKED
    export INTERNAL_STATIC_IP_MASKED
    export INTERNAL_GATEWAY_IP
    export EXTERNAL_GATEWAY_IP
    export INTERNAL_STATIC_IP

    export TCP_SVC_OUT
    export UDP_SVC_OUT
    export ICMP_SVC_OUT
    export TCP_SVC_IN
    export UDP_SVC_IN
    export ICMP_SVC_IN
}

###################################################################################################
# Name: 
#  startFirewall
# Description:
#  This function starts the firewall shell.
###################################################################################################
startFirewall()
{
    exportConfig

    if ! [ -f ${FIREWALL_PATH} ]; then
        echo "No such file or directory ${FIREWALL_PATH}. Please enter a new location."
    fi
    chmod +x $FIREWALL_PATH

    echo 'Setting up the firewall subnet routing'

    ethtool -s $INTERNAL_DEVICE mdix on

    ip link set $INTERNAL_DEVICE up
    ip addr add $INTERNAL_GATEWAY_IP_MASKED dev $INTERNAL_DEVICE

    echo "1" >/proc/sys/net/ipv4/ip_forward

    iptables -t nat -A POSTROUTING -o $EXTERNAL_DEVICE -j MASQUERADE

    if [ -f /etc/resolv.conf ]; then
        mv /etc/resolv.conf /etc/resolv.conf.old
    fi

    echo nameserver 8.8.8.8 > /etc/resolv.conf    

    echo 'Starting the firewall'
    sh $FIREWALL_PATH
}

###################################################################################################
# Name: 
#  disableFirewall
# Description:
#  This function disables the firewall.
###################################################################################################
disableFirewall()
{
    echo 'Disabling the firewall.'
    iptables -t nat -F
    iptables -t mangle -F

    iptables -F
    iptables -X
    iptables -P INPUT ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -P FORWARD ACCEPT

    ethtool -s $INTERNAL_DEVICE mdix auto

    echo "0" >/proc/sys/net/ipv4/ip_forward
    
    ip addr delete $INTERNAL_GATEWAY_IP_MASKED dev $INTERNAL_DEVICE
    ip link set $INTERNAL_DEVICE down

    rm /etc/resolv.conf
    mv /etc/resolv.conf.old /etc/resolv.conf
}

###################################################################################################
# Name: 
#  resetSettings
# Description:
#  This function resets the settings of the firewall.
###################################################################################################
resetSettings()
{
    echo 'Resetting the firewall settings.'
    #DEFAULT VALUES
    FIREWALL_PATH=""

    # Service configuration
    TCP_SVC_OUT=()
    UDP_SVC_OUT=()
    ICMP_SVC_OUT=()
    TCP_SVC_IN=()

    INTERNAL_ADDRESS_SPACE=""
    INTERNAL_DEVICE=""
    EXTERNAL_ADDRESS_SPACE=""
    EXTERNAL_DEVICE=""

    disableFirewall
}

###################################################################################################
# Name: 
#  showCurrentSettings
# Description:
#  This function shows the current settings.
###################################################################################################
showCurrentSettings()
{
    echo 'The current setings of the firewall.'
    echo "The Firewall path is: ${FIREWALL_PATH}"
    echo "The following outbound TCP services are allowed:"
    for i in "${TCP_SVC_OUT[@]}"; do
        echo '                                            ' "$i"
    done
    echo "The following inbound TCP services are allowed:"
    for i in "${TCP_SVC_IN[@]}"; do
        echo '                                            ' "$i"
    done
    echo "The following outbound UDP services are allowed:"
    for i in "${UDP_SVC_OUT[@]}"; do
        echo '                                            ' "$i"
    done
    echo "The following inbound UDP services are allowed:"
    for i in "${UDP_SVC_IN[@]}"; do
        echo '                                            ' "$i"
    done
    echo "The following outbound ICMP services are allowed:"
    for i in "${ICMP_SVC_OUT[@]}"; do
        echo '                                            ' "$i"
    done
    echo "The following inbound ICMP services are allowed:"
    for i in "${ICMP_SVC_OUT[@]}"; do
        echo '                                            ' "$i"
    done
    echo "The Internal Address Space is: ${INTERNAL_ADDRESS_SPACE}"
    echo "The Internal Device is: ${INTERNAL_DEVICE}"
    echo "The External Address Space is: ${EXTERNAL_ADDRESS_SPACE}"
    echo "The External Device is: ${EXTERNAL_DEVICE}"
    echo "The Internal Masked Gateway IP is: ${INTERNAL_GATEWAY_IP_MASKED}"
    echo "The Internal Masked Static IP is: ${INTERNAL_STATIC_IP_MASKED}"
    echo "The External Masked Gateway IP is: ${EXTERNAL_GATEWAY_IP_MASKED}"
    echo "The Internal Gateway IP is: ${INTERNAL_GATEWAY_IP}"
    echo "The Internal Static IP is: ${INTERNAL_STATIC_IP}"
    echo "The External Gateway IP is: ${EXTERNAL_GATEWAY_IP}"
}

###################################################################################################
# Name: 
#  internalMachineSetup
# Description:
#  This function disables one of the internal machine's NICs, sets its default gateway to the
#  appropriate firewall NIC, and sets nameserver/resolv.conf to the be the same as the firewall's.
###################################################################################################
internalMachineSetup()
{
    echo 'Setting up the internal machine.'

    ip link set dev $EXTERNAL_DEVICE down
    ip link set dev $INTERNAL_DEVICE up
    ip addr add $INTERNAL_STATIC_IP_MASKED dev $INTERNAL_DEVICE
    ip route add default via $INTERNAL_GATEWAY_IP

    if [ -f /etc/resolv.conf ]; then
        mv /etc/resolv.conf /etc/resolv.conf.old
    fi

    echo nameserver 8.8.8.8 > /etc/resolv.conf
}

###################################################################################################
# Name: 
#  internalMachineReset
# Description:
#  This function restores the internal machine's NICs, routing and name server settings to their
#  old values;.
###################################################################################################
internalMachineReset()
{
    echo 'Resetting the internal machine.'

	ip route delete default via $INTERNAL_GATEWAY_IP
	ip addr delete $INTERNAL_STATIC_IP_MASKED dev $INTERNAL_DEVICE
	ip link set dev $INTERNAL_DEVICE down
	ip link set dev $EXTERNAL_DEVICE up

	rm /etc/resolv.conf
	mv /etc/resolv.conf.old /etc/resolv.conf
}

###################################################################################################
# Name: 
#  setDefaults
# Description:
#  This function resets the machine's NIC cards.
###################################################################################################
setDefaults()
{
    echo "Setting up default values."
    FIREWALL_PATH="./fw.sh"
 
    TCP_SVC_OUT="http;https;ssh"
    TCP_SVC_IN="ssh"
    UDP_SVC_OUT="bootpc;bootps"
    ICMP_SVC_IN="0"
    ICMP_SVC_OUT="8"

    INTERNAL_ADDRESS_SPACE="10.0.4.0/24"
    INTERNAL_DEVICE="enp3s2"
    EXTERNAL_ADDRESS_SPACE="192.168.0.0/24"
    EXTERNAL_DEVICE="eno1"

    INTERNAL_GATEWAY_IP_MASKED="10.0.4.1/24"
    INTERNAL_STATIC_IP_MASKED='10.0.4.254/24'
    EXTERNAL_GATEWAY_IP_MASKED="192.168.0.8/24"

    INTERNAL_GATEWAY_IP="10.0.4.1"
    INTERNAL_STATIC_IP='10.0.4.2'
    EXTERNAL_GATEWAY_IP="192.168.0.8"
}

###################################################################################################
# Name: 
#  configureGateway
# Description:
#  This function configures the internal and external masked/unmasked gateways/static IPs.
###################################################################################################
configureGateway()
{
    echo 'Enter the Masked Internal Gateway IP'
    read int_masked_gateway rest
    INTERNAL_GATEWAY_IP_MASKED=${int_masked_gateway}
    if [ -z ${INTERNAL_GATEWAY_IP_MASKED} ]; then
        echo "Please enter a valid Masked Internal Gateway IP."
    fi
    INTERNAL_GATEWAY_IP=$(echo $INTERNAL_GATEWAY_IP_MASKED | cut -d'/' -f 1)

    echo 'Enter the Masked Internal Static IP'
    read int_masked_static rest
    INTERNAL_STATIC_IP_MASKED=${int_masked_static}
    if [ -z ${INTERNAL_STATIC_IP_MASKED} ]; then
        echo "Please enter a valid Masked Internal Static IP."
    fi
    INTERNAL_STATIC_IP=$(echo $INTERNAL_STATIC_IP_MASKED | cut -d'/' -f 1)

    echo 'Enter the Masked External Gateway IP'
    read ext__masked_gateway rest
    EXTERNAL_GATEWAY_IP_MASKED=${ext__masked_gateway}
    if [ -z ${EXTERNAL_GATEWAY_IP_MASKED} ]; then
        echo "Please enter a valid Masked Internal Gateway IP."
    fi
    EXTERNAL_GATEWAY_IP=$(echo $EXTERNAL_GATEWAY_IP_MASKED | cut -d'/' -f 1)
}

###################################################################################################
# Name: 
#  splitServices
# Description:
#  Split a semicolon-separated list of services into an array. Unfortunately this code was
#  duplicated.
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
#  createTestScripts
# Description:
#  This function creates test scripts based on the current configuration.
###################################################################################################
createTestScripts()
{
    echo "Enter the test device's IP address."
    read TEST_ADDR REST
    echo "Generating tests using test device IP $TEST_ADDR, internal IP $INTERNAL_STATIC_IP."

    HPING_PROGRAM=''
    if [ "$#" == 2 ]; then
        HPING_PROGRAM=$2
    else
        HPING_PROGRAM='hping3'
    fi

    echo "Creating external_tests.sh. Run these tests from $TEST_ADDR."
    if [ -f external_tests.sh ]; then
        rm -f external_tests.sh
    fi
    touch external_tests.sh
    chmod +x external_tests.sh

    echo "Creating internal_tests.sh. Run these tests from $INTERNAL_STATIC_IP."
    if [ -f internal_tests.sh ]; then
        rm -f internal_tests.sh
    fi
    touch internal_tests.sh
    chmod +x internal_tests.sh

    echo "Creating fw_pre_test.sh. Run this script on the firewall machine after the firewall has been enabled and before running the test scripts."
    if [ -f fw_pre_test.sh ]; then
        rm -f fw_pre_test.sh
    fi
    touch fw_pre_test.sh
    chmod +x fw_pre_test.sh

    echo "Creating fw_post_test.sh. Run this script on the firewall machine after the external_tests.sh and internal_tests.sh have been run."
    cat test/fw_post_test_start.sh > fw_post_test.sh
    chmod +x fw_post_test.sh

    
    splitServices $TCP_SVC_IN
    TCP_IN_TEST_COUNT=${#RESULT[@]}
    echo '# TCP inbound tests.' >> ./external_tests.sh
    for i in "${RESULT[@]}"; do
        
        # Write the hping command to perform the test
        echo "Adding inbound test for TCP port $i."
        
        getServicePort $i tcp
        PORT=$RESOLVED

        echo "# Inbound test for TCP port $i." >> ./external_tests.sh
        echo "$HPING_PROGRAM -c 1 -p $PORT --syn $EXTERNAL_GATEWAY_IP &>/dev/null" >> ./external_tests.sh
    done

    splitServices $TCP_SVC_OUT
    TCP_OUT_TEST_COUNT=${#RESULT[@]}
    echo '# TCP outbound tests.' >> ./internal_tests.sh
    for i in "${RESULT[@]}"; do
        echo "Adding outbound test for TCP port $i."
        
        getServicePort $i tcp
        PORT=$RESOLVED

        echo "# Outbound $i (TCP) test." >> ./internal_tests.sh
        echo "$HPING_PROGRAM -c 1 -p $PORT --syn $TEST_ADDR &>/dev/null" >> ./internal_tests.sh
    done

    # Write the corresponding tests to the firewall test script
    echo "for (( i=0; i<$(( $TCP_IN_TEST_COUNT + $TCP_OUT_TEST_COUNT )); i++ )) do"                                 >> fw_post_test.sh
    echo "    echo \"Checking packet counts for tcp-in and tcp-out rule \$i.\""                                     >> fw_post_test.sh
    echo "    echo \"             pkts bytes target     prot opt in     out     source               destination\"" >> fw_post_test.sh
    echo "    echo \"tcp-in rule \$i:  \${TCP_IN_RESULTS[i]}\""                                                     >> fw_post_test.sh
    echo "    echo \"tcp-out rule \$i: \${TCP_OUT_RESULTS[i]}\""                                                    >> fw_post_test.sh
    echo                                                                                                            >> fw_post_test.sh
    echo "    getPacketCount \"\${TCP_IN_RESULTS[i]}\""                                                             >> fw_post_test.sh
    echo "    doPacketCountTest tcp-in \$i 1 \$COUNT"                                                               >> fw_post_test.sh
    echo                                                                                                            >> fw_post_test.sh
    echo "    getPacketCount \"\${TCP_OUT_RESULTS[i]}\""                                                            >> fw_post_test.sh
    echo "    doPacketCountTest tcp-out \$i 1 \$COUNT"                                                              >> fw_post_test.sh
    echo "    echo ''"                                                                                              >> fw_post_test.sh
    echo "done"                                                                                                     >> fw_post_test.sh
    echo                                                                                                            >> fw_post_test.sh

    splitServices $UDP_SVC_IN
    UDP_IN_TEST_COUNT=${#RESULT[@]}
    echo '# UDP inbound tests.' >> ./external_tests.sh
    for i in "${RESULT[@]}"; do
        
        # Write the hping command to perform the test
        echo "Adding inbound test for UDP port $i."
        
        getServicePort $i udp
        PORT=$RESOLVED

        echo "# Inbound test for UDP port $i." >> ./external_tests.sh
        echo "$HPING_PROGRAM -2 -c 1 -p $PORT $EXTERNAL_GATEWAY_IP &>/dev/null" >> ./external_tests.sh
    done

    splitServices $UDP_SVC_OUT
    UDP_OUT_TEST_COUNT=${#RESULT[@]}
    echo '# UDP outbound tests.' >> ./internal_tests.sh
    for i in "${RESULT[@]}"; do
        echo "Adding outbound test for UDP port $i."
        
        getServicePort $i tcp
        PORT=$RESOLVED

        echo "# Outbound $i (UDP) test." >> ./internal_tests.sh
        echo "$HPING_PROGRAM -2 -c 1 -p $PORT $TEST_ADDR &>/dev/null" >> ./internal_tests.sh
    done

    echo "for (( i=0; i<$UDP_IN_TEST_COUNT; i++ )) do"                                                              >> fw_post_test.sh
    echo "    echo \"Checking packet counts for udp-in rule \$i.\""                                                 >> fw_post_test.sh
    echo "    echo \"             pkts bytes target     prot opt in     out     source               destination\"" >> fw_post_test.sh
    echo "    echo \"udp-in rule \$i:  \${UDP_IN_RESULTS[i]}\""                                                     >> fw_post_test.sh
    echo                                                                                                            >> fw_post_test.sh
    echo "    getPacketCount \"\${ICMP_IN_RESULTS[i]}\""                                                            >> fw_post_test.sh
    echo "    doPacketCountTest udp-in \$i 1 \$COUNT"                                                               >> fw_post_test.sh
    echo                                                                                                            >> fw_post_test.sh
    echo "    echo ''"                                                                                              >> fw_post_test.sh
    echo "done"                                                                                                     >> fw_post_test.sh
    echo                                                                                                            >> fw_post_test.sh
    echo "for (( i=$UDP_IN_TEST_COUNT; i<$(( $UDP_IN_TEST_COUNT + $UDP_OUT_TEST_COUNT )); i++ )) do"                >> fw_post_test.sh
    echo "    ACTUAL_RULE=\$(( \$i - $UDP_IN_TEST_COUNT ))"                                                         >> fw_post_test.sh
    echo "    echo \"Checking packet counts for udp-out rule \$ACTUAL_RULE.\""                                      >> fw_post_test.sh
    echo "    echo \"             pkts bytes target     prot opt in     out     source               destination\"" >> fw_post_test.sh
    echo "    echo \"udp-out rule \$i:  \${UDP_OUT_RESULTS[i]}\""                                                   >> fw_post_test.sh
    echo                                                                                                            >> fw_post_test.sh
    echo "    getPacketCount \"\${UDP_OUT_RESULTS[i]}\""                                                            >> fw_post_test.sh
    echo "    doPacketCountTest udp-out \$i 1 \$COUNT"                                                              >> fw_post_test.sh
    echo                                                                                                            >> fw_post_test.sh
    echo "    echo ''"                                                                                              >> fw_post_test.sh
    echo "done"                                                                                                     >> fw_post_test.sh
    echo                                                                                                            >> fw_post_test.sh

    splitServices $ICMP_SVC_IN
    ICMP_IN_TEST_COUNT=${#RESULT[@]}
    echo '# ICMP inbound tests.' >> ./external_tests.sh
    for i in "${RESULT[@]}"; do
        
        # Write the hping command to perform the test
        echo "Adding inbound test for ICMP type $i."
        echo "# Inbound test for ICMP type $i." >> ./external_tests.sh
        echo "$HPING_PROGRAM -c 1 -C $i $EXTERNAL_GATEWAY_IP &>/dev/null" >> ./external_tests.sh
    done

    splitServices $ICMP_SVC_OUT
    ICMP_OUT_TEST_COUNT=${#RESULT[@]}
    echo '# ICMP outbound tests.' >> ./internal_tests.sh
    for i in "${RESULT[@]}"; do
        echo "Adding outbound test for ICMP type $i."
        echo "# Outbound $i (UDP) test." >> ./internal_tests.sh
        echo "$HPING_PROGRAM -c 1 -C $i $TEST_ADDR &>/dev/null" >> ./internal_tests.sh
    done

    echo "for (( i=0; i<$ICMP_IN_TEST_COUNT; i++ )) do"                                                             >> fw_post_test.sh
    echo "    echo \"Checking packet counts for icmp-in rule \$i.\""                                                >> fw_post_test.sh
    echo "    echo \"             pkts bytes target     prot opt in     out     source               destination\"" >> fw_post_test.sh
    echo "    echo \"icmp-in rule \$i:  \${ICMP_IN_RESULTS[i]}\""                                                   >> fw_post_test.sh
    echo                                                                                                            >> fw_post_test.sh
    echo "    getPacketCount \"\${ICMP_IN_RESULTS[i]}\""                                                            >> fw_post_test.sh
    echo "    doPacketCountTest icmp-in \$i 1 \$COUNT"                                                              >> fw_post_test.sh
    echo                                                                                                            >> fw_post_test.sh
    echo "    echo ''"                                                                                              >> fw_post_test.sh
    echo "done"                                                                                                     >> fw_post_test.sh
    echo                                                                                                            >> fw_post_test.sh
    echo "for (( i=0; i<$ICMP_OUT_TEST_COUNT; i++ )) do"                                                            >> fw_post_test.sh
    echo "    echo \"Checking packet counts for icmp-out rule \$i.\""                                               >> fw_post_test.sh
    echo "    echo \"             pkts bytes target     prot opt in     out     source               destination\"" >> fw_post_test.sh
    echo "    echo \"icmp-out rule \$i:  \${ICMP_OUT_RESULTS[i]}\""                                                 >> fw_post_test.sh
    echo                                                                                                            >> fw_post_test.sh
    echo "    getPacketCount \"\${ICMP_OUT_RESULTS[i]}\""                                                           >> fw_post_test.sh
    echo "    doPacketCountTest icmp-out \$i 1 \$COUNT"                                                             >> fw_post_test.sh
    echo                                                                                                            >> fw_post_test.sh
    echo "    echo ''"                                                                                              >> fw_post_test.sh
    echo "done"                                                                                                     >> fw_post_test.sh
 
    # For testing purposes, only allow packets to/from the test device
    # That way, we can test against expected packet counts
    echo "iptables -N check-dest-addr"                              >> ./fw_pre_test.sh
    echo "iptables -A check-dest-addr ! -d $TEST_ADDR -j DROP"      >> ./fw_pre_test.sh
    echo "iptables -I FORWARD 1 ! -s $TEST_ADDR -j check-dest-addr" >> ./fw_pre_test.sh
    echo "iptables -Z"                                              >> ./fw_pre_test.sh

    echo                               >> ./fw_post_test.sh
    echo "iptables -F check-dest-addr" >> ./fw_post_test.sh
    echo "iptables -D FORWARD 1"       >> ./fw_post_test.sh
    echo "iptables -X check-dest-addr" >> ./fw_post_test.sh
}

###################################################################################################
# Name: 
#  mainMenu
# Description:
#  This function is the main menu of the program. It displays the
#  options available. The user is able to choose and option and
#  the program will go to the corresponding action.
###################################################################################################
mainMenu()
{
    while true
    do
    clear
    displayMenu
    read ltr rest
    case ${ltr} in
        1)      showCurrentSettings
                continueApplication
                mainMenu;;
        2)      setDefaults
                continueApplication
                mainMenu;;
        3)      resetSettings
                continueApplication
                mainMenu;;
        4)      configureFirewallLocation
                continueApplication
                mainMenu;;
        5)      configureExternalAddressSpaceAndDevice
                continueApplication
                mainMenu;;
        6)      configureInternalAddressSpaceAndDevice
                continueApplication
                mainMenu;;
        7)      configureTCPServices
                continueApplication
                mainMenu;;
        8)      configureUDPServices
                continueApplication
                mainMenu;;
        9)      configureICMPServices
                continueApplication
                mainMenu;;
       10)      configureGateway
                continueApplication
                mainMenu;;
       11)      internalMachineSetup
                continueApplication
                mainMenu;;
       12)      internalMachineReset
                continueApplication
                mainMenu;;
       13)      createTestScripts
                continueApplication
                mainMenu;;
       14)      startFirewall
                continueApplication
                mainMenu;;
       15)      disableFirewall
                continueApplication
                mainMenu;;
     [Qq])      exit;;
        *)      echo
        
                echo Unrecognized choice: ${ltr}
                        continueApplication
                        mainMenu
                ;;
    esac        
    done
}

###################################################################################################
# Name: 
#  displayMenu
# Description:
#  This function displays the menu options to the user.
###################################################################################################
displayMenu()
{
    cat << 'MENU'
        Welcome to Assignment #2: Standalone Firewall
        By Mat Siwoski & Shane Spoor
        
        1............................  Show Current Settings
        2............................  Set Defaults
        3............................  Reset Settings
        4............................  Specify Firewall Script Location/Name
        5............................  Customise External Address Space and Device
        6............................  Customise Internal Address Space and Device
        7............................  Configure TCP Services
        8............................  Configure UDP Services
        9............................  Configure ICMP Services
        10...........................  Configure the Gateway
        11..........................   Set up Internal Machine
        12..........................   Reset Internal Machine
        13...........................  Generate Test Scripts
        14...........................  Start Firewall
        15...........................  Disable Firewall

        Q............................  Quit

MENU
   echo -n '      Press a Number for your choice, then Return > '
}

mainMenu
