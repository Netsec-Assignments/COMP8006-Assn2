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
TCP_SERVICES=""
UDP_SERVICES=""
ICMP_SERVICES=""

INTERNAL_ADDRESS_SPACE=""
INTERNAL_DEVICE=""
EXTERNAL_ADDRESS_SPACE=""
EXTERNAL_DEVICE=""


STATIC_IP="10.0.4.2/24"
GATEWAY_IP="10.0.4.1/24"


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
#  configureInteranlAddressSpaceAndDevice
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
#  configureInteranlAddressSpaceAndDevice
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
    echo 'Enter a semicolon-separated list of allowed TCP services.'
    read LIST REST
    IFS=';' read -ra SPLIT_LIST <<< "$LIST"
    for i in "${SPLIT_LIST[@]}"; do
        SERVICE=`getent services $i/tcp`
        echo "SERVICE is: $SERVICE"
        if [ -z "$SERVICE" ]; then
            echo "No such service $i for TCP. Please enter a valid service name or port number."
        else
            TCP_SERVICES+="$i;"
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
        echo "SERVICE is: $SERVICE"
        if [ -z "$SERVICE" ]; then
            echo "No such service $i for UDP. Please enter a valid service name or port number."
        else
            UDP_SERVICES+="$i;"
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
    echo 'Enter a semicolon-separated list of allowed ICMP services (by type; see below).'
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
            echo "Type is: $i"
            ICMP_SERVICES+="$i;"
        fi        
    done
}

###################################################################################################
# Name: 
#  startFirewall
# Description:
#  This function starts the firewall shell.
###################################################################################################
startFirewall()
{
    echo 'Starting the firewall'
    export INTERNAL_ADDRESS_SPACE INTERNAL_DEVICE EXTERNAL_ADDRESS_SPACE EXTERNAL_DEVICE TCP_SERVICES UDP_SERVICES ICMP_SERVICES
    if ! [ -f ${FIREWALL_PATH} ]; then
        echo "No such file or directory ${FIREWALL_PATH}. Please enter a new location."
    fi
    chmod +x $FIREWALL_PATH
    sh $FIREWALL_PATH
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
	TCP_SERVICES=()
	UDP_SERVICES=()
	ICMP_SERVICES=()

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
    for i in "${TCP_SERVICES[@]}"; do
        echo '                                            ' "$i"
    done
    echo "The following UDP services are selected:"
	for i in "${UDP_SERVICES[@]}"; do
		echo '                                            ' "$i"
	done
 	echo "The following ICMP services are selected:"
	for i in "${ICMP_SERVICES[@]}"; do
		echo '                                            ' "$i"
	done    
    echo "The Internal Address Space is: ${INTERNAL_ADDRESS_SPACE}"
    echo "The Internal Device is: ${INTERNAL_DEVICE}"
    echo "The External Address Space is: ${EXTERNAL_ADDRESS_SPACE}"
    echo "The External Device is: ${EXTERNAL_DEVICE}"
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
	iptables -F
	iptables -X
	iptables -P INPUT ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD ACCEPT
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

	ip link set eno1 down
	ip addr add $STATIC_IP 
	ip link set enp3s2 up
	ip route add default via $GATEWAY_IP
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

	ip link set eno1 up
	ip link set enp3s2 down
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

    ip a add $INTERNAL_GATEWAY_IP dev $INTERNAL_DEVICE
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
 
	TCP_SERVICES="domain;http;https;ssh"
	UDP_SERVICES="domain;bootpc;bootps"
	ICMP_SERVICES="0;8"

	INTERNAL_ADDRESS_SPACE="10.0.4.0/24"
	INTERNAL_DEVICE="enp3s2"
	EXTERNAL_ADDRESS_SPACE="192.168.0.0/24"
	EXTERNAL_DEVICE="eno1"
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
		7)		showCurrentSettings
				continueApplication
		        mainMenu;;
		8)		startFirewall
				continueApplication
		        mainMenu;;
		9)		resetSettings
				continueApplication
		        mainMenu;;
		10)		disableFirewall
				continueApplication
		        mainMenu;;
		11)		setupRouting
				continueApplication
		        mainMenu;;
		12)		resetRouting
				continueApplication
		        mainMenu;;
		13)		internalMachineSetup
				continueApplication
		        mainMenu;;
		14)		resetMachine
				continueApplication
		        mainMenu;;
		15)		setDefaults
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
        7............................  Show Current Settings
        8............................  Start Firewall
        9............................  Reset Settings
        10...........................  Disable Firewall
        11...........................  Enable Routing
        12...........................  Disable Routing
        13...........................  Enable the NIC 
        14...........................  Reset the NIC on the machine
        15...........................  Set Defaults

        Q............................  Quit

MENU
   echo -n '      Press a Number for your choice, then Return > '
}

mainMenu
