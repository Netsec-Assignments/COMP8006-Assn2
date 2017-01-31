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
TCP_SERVICES=()
UDP_SERVICES=()
ICMP_SERVICES=()

INTERNAL_ADDRESS_SPACE=""
INTERNAL_DEVICE=""
EXTERNAL_ADDRESS_SPACE=""
EXTERNAL_DEVICE=""

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
    
    echo -n 'Enter the internal network device'
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
    
    echo -n 'Enter the external network device'
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
            TCP_SERVICES+=("$i")
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
            UDP_SERVICES+=("$i")
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
            ICMP_SERVICES+=("$i")    
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
#  startFirewall
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
        echo '                                        %s\n' "$i"
    done
    echo "The following UDP services are selected:"
	for i in "${UDP_SERVICES[@]}"; do
		echo '                                        %s\n' "$i"
	done
 	echo "The following ICMP services are selected:"
	for i in "${ICMP_SERVICES[@]}"; do
		echo '                                        %s\n' "$i"
	done    
    echo "The Internal Address Space is: ${INTERNAL_ADDRESS_SPACE}"
    echo "The Internal Device is: ${INTERNAL_DEVICE}"
    echo "The External Address Space is: ${EXTERNAL_ADDRESS_SPACE}:"
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
		[1])	configureFirewallLocation
				continueApplication
				mainMenu;;
		[2])	configureExternalAddressSpaceAndDevice
        	    continueApplication
                mainMenu;;
		[3])    configureInternalAddressSpaceAndDevice
		        continueApplication
		        mainMenu;;
		[4])	configureTCPServices
		        continueApplication
		        mainMenu;;
		[5])	configureUDPServices
		        continueApplication
		        mainMenu;;
		[6])	configureICMPServices
		        continueApplication
		        mainMenu;;
		[7])	showCurrentSettings
				continueApplication
		        mainMenu;;
		[8])	resetSettings
				continueApplication
		        mainMenu;;
		[9])	startFirewall
				continueApplication
		        mainMenu;;
		[10])	disableFirewall
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
        8............................  Reset Settings
        9............................  Start Firewall
        10...........................  Disable Firewall
        Q............................  Quit

MENU
   echo -n '      Press  letter for choice, then Return > '
}

mainMenu
