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
    ----	-------------------------
      0	    Echo Reply				 
      1	    Unassigned				 
      2	    Unassigned				 
      3	    Destination Unreachable	
      4	    Source Quench			
      5	    Redirect				
      6	    Alternate Host Address	
      7	    Unassigned				
      8	    Echo					
      9	    Router Advertisement	
     10	    Router Selection		
     11	    Time Exceeded			
     12	    Parameter Problem		
     13	    Timestamp				
     14	    Timestamp Reply			
     15	    Information Request		
     16	    Information Reply		
     17	    Address Mask Request    
     18	    Address Mask Reply		
     19	    Reserved (for Security)	
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
    echo "The following TCP services are selected:"
    for i in "${TCP_SVC_OUT[@]}"; do
        echo '                                            ' "$i"
    done
    echo "The following UDP services are selected:"
	for i in "${UDP_SVC_OUT[@]}"; do
		echo '                                            ' "$i"
	done
 	echo "The following ICMP services are selected:"
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
#  This function disables the NIC card.
###################################################################################################
internalMachineSetup()
{
    echo 'Setting up the internal machine'

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
#  resetMachine
# Description:
#  This function resets the machine's NIC cards.
###################################################################################################
resetMachine()
{
    echo 'Resetting the machine.'

	ip route delete default via $INTERNAL_GATEWAY_IP
	ip addr delete $INTERNAL_STATIC_IP_MASKED dev $INTERNAL_DEVICE
	ip link set dev $INTERNAL_DEVICE down
	ip link set dev $EXTERNAL_DEVICE up

	rm /etc/resolv.conf
	mv /etc/resolv.conf.old /etc/resolv.conf
}

###################################################################################################
# Name: 
#  setupRouting
# Description:
#  This function sets up routing on the device.
###################################################################################################
setupRouting()
{
    ethtool -s $INTERNAL_DEVICE mdix on

    ip addr add $INTERNAL_GATEWAY_IP_MASKED dev $INTERNAL_DEVICE
    ip link set $INTERNAL_DEVICE up

    echo "1" >/proc/sys/net/ipv4/ip_forward

    ip route add $EXTERNAL_ADDRESS_SPACE via $EXTERNAL_GATEWAY_IP dev $EXTERNAL_DEVICE
    ip route add $INTERNAL_ADDRESS_SPACE via $INTERNAL_GATEWAY_IP dev $INTERNAL_DEVICE
}

###################################################################################################
# Name: 
#  resetRouting
# Description:
#  This function resets the machine's NIC cards.
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
#  setDefaults
# Description:
#  This function resets the machine's NIC cards.
###################################################################################################
setDefaults()
{
	echo "Setting up default values."
	FIREWALL_PATH="./fw.sh"
 
	TCP_SVC_OUT="domain;http;https;ssh"
    TCP_SVC_IN="ssh"
	UDP_SVC_OUT="domain;bootpc;bootps"
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

writeHpingTest()
{
    SCRIPT_FILE=$1
    EXIT_PASS=$2
    TEST_NAME=$3

    echo "if [ \$? == $EXIT_PASS ]; then" >> $SCRIPT_FILE
    echo "    echo '$TEST_NAME: passed'"  >> $SCRIPT_FILE
    echo "else"                           >> $SCRIPT_FILE
    echo "    echo '$TEST_NAME: failed'"  >> $SCRIPT_FILE
    echo "fi"                             >> $SCRIPT_FILE
    echo ''                               >> $SCRIPT_FILE
}

writeTestChainCreation()
{
    SCRIPT_FILE=$1
    PROTOCOL=$2
    TEST_ADDR=$3

    # All packets coming from and going to the test address will be tracked.
    # 
    # If a packet is accepted, it will add 1 to $PROTOCOL-[in|out]-start but
    # not $PROTOCOL-[in|out]-end; if the packet traverses all chains in
    # $PROTOCOL-[in|out] and doesn't match (i.e., it's dropped), it will also
    # add to $PROTOCOL-[in|out]-end. We can check the final counts of those
    # chains to determine how many packets were accepted/dropped and compare
    # against the expected results given the rules to check that rules are
    # working as expected.
    echo "iptables -N $PROTOCOL-in-start"                          >> $SCRIPT_FILE
    echo "iptables -A $PROTOCOL-in-start -s $TEST_ADDR -j RETURN"  >> $SCRIPT_FILE
    echo "iptables -I $PROTOCOL-in 0 -j $PROTOCOL-in-start"        >> $SCRIPT_FILE
    echo ''                                                        >> $SCRIPT_FILE
    echo "iptables -N $PROTOCOL-in-end"                            >> $SCRIPT_FILE
    echo "iptables -A $PROTOCOL-in-end -s $TEST_ADDR -j RETURN"    >> $SCRIPT_FILE
    echo "iptables -A $PROTOCOL-in -j $PROTOCOL-in-end"            >> $SCRIPT_FILE
    echo ''                                                        >> $SCRIPT_FILE
    echo "iptables -N $PROTOCOL-out-start"                         >> $SCRIPT_FILE
    echo "iptables -A $PROTOCOL-out-start -d $TEST_ADDR -j RETURN" >> $SCRIPT_FILE
    echo "iptables -I $PROTOCOL-out 0 -j $PROTOCOL-out-start"      >> $SCRIPT_FILE
    echo ''                                                        >> $SCRIPT_FILE
    echo "iptables -N $PROTOCOL-out-end"                           >> $SCRIPT_FILE
    echo "iptables -A $PROTOCOL-out-end -d $TEST_ADDR -j RETURN"   >> $SCRIPT_FILE
    echo "iptables -A $PROTOCOL-out -j $PROTOCOL-out-end"          >> $SCRIPT_FILE    
}

writeTestChainDeletion()
{
    SCRIPT_FILE=$1
    PROTOCOL=$2

    echo "iptables -R $PROTOCOL-in 0"                     >> $SCRIPT_FILE
    echo "iptables -D $PROTOCOL-in-start"                 >> $SCRIPT_FILE
    echo ''                                               >> $SCRIPT_FILE
    echo "iptables -A $PROTOCOL-in -j $PROTOCOL-in-end"   >> $SCRIPT_FILE
    echo "iptables -D $PROTOCOL-in-end"                   >> $SCRIPT_FILE
    echo ''                                               >> $SCRIPT_FILE
    echo "iptables -R $PROTOCOL-out 0"                    >> $SCRIPT_FILE
    echo "iptables -D $PROTOCOL-out-start"                >> $SCRIPT_FILE
    echo ''                                               >> $SCRIPT_FILE
    echo "iptables -R $PROTOCOL-out -j $PROTOCOL-out-end" >> $SCRIPT_FILE
    echo "iptables -D $PROTOCOL-out-end"                  >> $SCRIPT_FILE    
    
}

writePacketCountTest()
{
    SCRIPT_FILE=$1
    CHAIN=$2
    EXPECTED_COUNT=$3

    echo "COUNT=\$(iptables -vL $CHAIN | sed '3q;d' | awk '{print \$1}')"                 >> $SCRIPT_FILE
    echo "if [ \$COUNT == $EXPECTED_COUNT ]; then"                                        >> $SCRIPT_FILE
    echo "    echo 'chain $CHAIN had expected packet count $EXPECTED_COUNT.'"             >> $SCRIPT_FILE
    echo "else"                                                                           >> $SCRIPT_FILE
    echo "    echo \"chain $CHAIN had packet count \$COUNT, should be $EXPECTED_COUNT.\"" >> $SCRIPT_FILE
    echo "fi"                                                                             >> $SCRIPT_FILE
    echo ''                                                                               >> $SCRIPT_FILE
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
    if [ -f ./external_tests.sh ]; then
        rm -f ./external_tests.sh
    fi
    touch ./external_tests.sh
    chmod +x ./external_tests.sh

    echo "Creating internal_tests.sh. Run these tests from $INTERNAL_STATIC_IP."
    if [ -f ./external_tests.sh ]; then
        rm -f ./external_tests.sh
    fi
    touch ./external_tests.sh
    chmod +x ./external_tests.sh

    echo "Creating fw_pre_test.sh. Run this script on the firewall machine after the firewall has been enabled and before running the test scripts."
    if [ -f ./fw_pre_test.sh ]; then
        rm -f ./fw_pre_test.sh
    fi
    touch ./fw_pre_test.sh
    chmod +x ./fw_pre_test.sh

    echo "Creating fw_post_test.sh. Run this script on the firewall machine after the external_tests.sh and internal_tests.sh have been run."
    if [ -f ./fw_post_test.sh ]; then
        rm -f ./fw_post_test.sh
    fi
    touch ./fw_post_test.sh
    chmod +x ./fw_post_test.sh

    # TCP tests can check the return value of hping3 since they should actually get a response
    # All other tests are verified only by the firewall pre/post test scripts.

    splitServices $TCP_SVC_IN
    EXPECTED_TCP_IN_ACCEPTED=0
    EXPECTED_TCP_IN_DROPPED=0
    echo '# TCP inbound tests.' >> ./external_tests.sh
    for i in "${RESULT[@]}"; do
        echo "Adding inbound tests for $i."
        
        echo "# Inbound $i tests." >> ./external_tests.sh
        # Allowed input
        echo "$HPING_PROGRAM -c 1 -p $i --syn $EXTERNAL_GATEWAY_IP" >> ./external_tests.sh
        writeHpingTest ./external_tests.sh 0 "$i inbound"

        # Disallowed input: syn/fin, syn/ack, all flags, no flags (could do more combos)
        echo "$HPING_PROGRAM -c 1 -p $i --syn --fin $EXTERNAL_GATEWAY_IP" >> ./external_tests.sh
        writeHpingTest ./external_tests.sh 1 "$i inbound SYN/FIN"

        echo "$HPING_PROGRAM -c 1 -p $i --syn --ack $EXTERNAL_GATEWAY_IP" >> ./external_tests.sh
        writeHpingTest ./external_tests.sh 1 "$i inbound SYN/ACK"

        echo "$HPING_PROGRAM -c 1 -p $i --syn --ack --push --urg --fin --rst $EXTERNAL_GATEWAY_IP" >> ./external_tests.sh
        writeHpingTest ./external_tests.sh 1 "$i inbound Christmas tree"

        echo "$HPING_PROGRAM -c 1 -p $i $EXTERNAL_GATEWAY_IP" >> ./external_tests.sh
        writeHpingTest ./external_tests.sh 1 "$i inbound no flags"

        echo '' >> ./external_tests.sh

        (( EXPECTED_TCP_IN_ACCEPTED += 1 ))
        (( EXPECTED_TCP_IN_DROPPED += 4 ))
    done

    splitServices $TCP_SVC_OUT
    EXPECTED_TCP_OUT_ACCEPTED=0
    echo '# TCP outbound tests.' >> ./external_tests.sh
    for i in "${RESULT[@]}"; do
        echo "Adding outbound test for $i."
        
        echo "# Outbound $i test." >> ./external_tests.sh
        echo "$HPING_PROGRAM -c 1 -p $i --syn $EXTERNAL_GATEWAY_IP" >> ./external_tests.sh
        writeHpingTest ./external_tests.sh 0 "$i inbound"

        (( EXPECTED_TCP_OUT_ACCEPTED += 1 ))
    done

    writeTestChainCreation ./fw_pre_test.sh tcp $TEST_ADDR
    writePacketCountTest ./fw_post_test.sh tcp-in-start $(( $EXPECTED_TCP_IN_ACCEPTED + $EXPECTED_TCP_IN_DROPPED ))
    writePacketCountTest ./fw_post_test.sh tcp-in-end $EXPECTED_TCP_IN_DROPPED

    # Create test chains
    # In the firewall, we create a user-defined chain "explicit_drop" (or similar) with default dropped packets
    # We also create tcp-in, tcp-out, upd-in, udp-out, etc.
    # Insert test-tcp-in-start chain to the beginning of tcp-in and test-tcp-in-end at the end. These will take the test device's IP into account.
    # Perform all tests on both machines (external and internal).
    # Check final counts for each chain. We won't get the same granularity, but if there are problems, we can at least isolate the chain (tcp-in, tcp-out, etc.)
    # with failing tests.
    # "Check final counts" means:
    #   all packets that should be dropped by default hit the first chain in the default drop chain but not the last one
    #   all packets that should make it through the dropped by default hit the first chain and the last one
    #   etc. for the other chains, except reversed

#    if [ -f ./internal_tests.sh ]; then
#        
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
		1)		configureFirewallLocation
				continueApplication
				mainMenu;;
		2)		configureExternalAddressSpaceAndDevice
        	    continueApplication
                mainMenu;;
		3)	    configureInternalAddressSpaceAndDevice
		        continueApplication
		        mainMenu;;
		4)		configureTCPServices
		        continueApplication
		        mainMenu;;
		5)		configureUDPServices
		        continueApplication
		        mainMenu;;
		6)		configureICMPServices
		        continueApplication
		        mainMenu;;
		7)		configureGateway
				continueApplication
		        mainMenu;;
		8)		showCurrentSettings
				continueApplication
		        mainMenu;;
		9)		startFirewall
				continueApplication
		        mainMenu;;
		10)		setupRouting
				continueApplication
		        mainMenu;;
		11)		internalMachineSetup
				continueApplication
		        mainMenu;;
		12)		resetSettings
				continueApplication
		        mainMenu;;
		13)		disableFirewall
				continueApplication
		        mainMenu;;
		14)		resetRouting
				continueApplication
		        mainMenu;;
		15)		resetMachine
				continueApplication
		        mainMenu;;
		16)		setDefaults
				continueApplication
		        mainMenu;;
		17)		createTestScripts
				continueApplication
		        mainMenu;;
	    [Qq])	exit	;;
	    *)	echo
	    
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
        
        1............................  Specify Firewall Script Location/Name
        2............................  Customise External Address Space and Device
        3............................  Customise Internal Address Space and Device      
        4............................  Configure TCP Services
        5............................  Configure UDP Services
        6............................  Configure ICMP Services
        7............................  Configure the Gateway
        8............................  Show Current Settings
        9............................  Start Firewall
        10..........................   Enable Routing
        11...........................  Set up Internal Machine 
        12...........................  Reset Settings
        13...........................  Disable Firewall
        14...........................  Disable Routing
        15...........................  Reset the NIC on the machine
        16...........................  Set Defaults
        17...........................  Generate Test Scripts

        Q............................  Quit

MENU
   echo -n '      Press a Number for your choice, then Return > '
}

mainMenu
