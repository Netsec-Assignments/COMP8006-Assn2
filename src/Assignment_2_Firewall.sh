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

#DEFAULT VALUES
INTERNALADDRESS=""
INTERNALDEVICE=""
EXTERNALADDRESS=""
EXTERNALDEVICE=""

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
	    [Cc])	customizeOptions
                mainMenu;;
	    [Ee])	deleteFilters
			    resetFilters
			    createChainForWWWSSH
			    allowDNSAndDHCPTraffic
			    dropPortEightyToTenTwentyFour
			    permitInboundOutboundSSH
			    permitInboundOutboundWWW
			    permitInboundOutboundSSL
			    dropInvalidTCPPacketsInbound			
			    dropPortZeroTraffic
			    setDefaultToDrop
			    continueApplication
			    mainMenu;;
	    [Ll])   listAllRules
			    continueApplication
			    mainMenu;;
	    [Rr])   deleteFilters
			    resetFilters
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
        Welcome to Lab #2: Personal Firewall
        By Mat Siwoski & Shane Spoor
        
        C...........................  Customize Firewall Settings
        E...........................  Enable Firewall
	    L...........................  List all chains
        R...........................  Reset/Disable Firewall
        Q...........................  Quit

MENU
    echo -n '      Press  letter for choice, then Return > '
}


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
#  customizeOptions
# Description:
#  This function handles the option customizations.
###################################################################################################
continueApplication()
{
    echo
    echo -n ' Press Enter to continue.....'
    read rest
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
	iptables -P INPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -P INPUT ACCEPT
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
	iptables -P INPUT DROP
	iptables -P FORWARD DROP
	iptables -P OUTPUT DROP
}

###################################################################################################
# Name: 
#  createChainForWWWSSH
# Description:
#  This function creates the chains for SSH and WWW traffic.
###################################################################################################
createChainForWWWSSH()
{
	echo 'Creating chains for SSH and WWW Traffic'
	iptables -N ssh-in
	iptables -N ssh-out
	iptables -A ssh-in -j ACCEPT
	iptables -A ssh-out -j ACCEPT
	iptables -N www-in
	iptables -N www-out
	iptables -A www-in -j ACCEPT
	iptables -A www-out -j ACCEPT
	iptables -N other-in
	iptables -N other-out	
	iptables -A other-in -j ACCEPT
	iptables -A other-out -j ACCEPT
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
#  dropPortEightyToTenTwentyFour
# Description:
#  This function drops inbound traffic to port 80 (http) from source ports less than 1024.
###################################################################################################
dropPortEightyToTenTwentyFour()
{
	echo 'Drop inbound traffic to port 80 (http) from source ports less than 1024.'
	iptables -A INPUT -p tcp --dport 80 --sport 0:1023 -j DROP
}

###################################################################################################
# Name: 
#  allowDNSAndDHCPTraffic
# Description:
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
#  permitInboundOutboundSSH
# Description:
#  This function permits inbound and outbound traffic on SSH
###################################################################################################
permitInboundOutboundSSH()
{
	echo 'Permit inbound and outbound traffic on SSH'
	iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED,RELATED -j ssh-in
	iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED,RELATED -j ssh-out
	iptables -A INPUT -p tcp --sport 22 -m state --state ESTABLISHED,RELATED -j ssh-in
	iptables -A OUTPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED,RELATED -j ssh-out
}

###################################################################################################
# Name: 
#  permitInboundOutboundWWW
# Description:
#  This function permits inbound and outbound traffic on WWW (Port 80)
###################################################################################################
permitInboundOutboundWWW()
{
	echo 'Permit inbound and outbound traffic on WWW (Port 80)'
	iptables -A INPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j www-in
	iptables -A OUTPUT -p tcp --sport 80 -m state --state ESTABLISHED -j www-out
	iptables -A INPUT -p tcp --sport 80 -m state --state ESTABLISHED -j www-in
	iptables -A OUTPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j www-out
}

###################################################################################################
# Name: 
#  permitInboundOutboundSSL
# Description:
#  This function permits inbound and outbound traffic on SSL (Port 443)
###################################################################################################
permitInboundOutboundSSL()
{
	echo 'Permit inbound and outbound traffic on SSL (Port 443)'
	iptables -A INPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j www-in
	iptables -A OUTPUT -p tcp --sport 443 -m state --state ESTABLISHED -j www-out
	iptables -A INPUT -p tcp --sport 443 -m state --state ESTABLISHED -j www-in
	iptables -A OUTPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j www-out
}

###################################################################################################
# Name: 
#  dropInvalidTCPPacketsInbound
# Description:
#  This function drops invalid TCP Packets that are inbound
###################################################################################################
dropInvalidTCPPacketsInbound()
{
	echo 'Drop invalid TCP Packets that are inbound'
	iptables -A INPUT -p tcp --syn -j DROP
	iptables -A INPUT -p tcp --tcp-flags ALL ACK,RST,SYN,FIN -j DROP
	iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
	iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
	iptables -A INPUT -p tcp --tcp-flags SYN,FIN,PSH SYN,FIN,PSH -j DROP
	iptables -A INPUT -p tcp --tcp-flags ALL ACK,URG -j DROP
	iptables -A INPUT -p tcp --tcp-flags FIN FIN -j DROP
	iptables -A INPUT -p tcp --tcp-flags FIN,URG,PSH FIN,URG,PSH -j DROP
	iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
	iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
}

###################################################################################################
# Name: 
#  listAllRules
# Description:
#  This function list all the rules for the chains
###################################################################################################
listAllRules()
{
	echo 'List all the rules for the chains'
	iptables -L -v
}

mainMenu
