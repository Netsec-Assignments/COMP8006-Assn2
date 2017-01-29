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
        Welcome to Assignment #2: Standalone Firewall
        By Mat Siwoski & Shane Spoor
        
        L...........................  Specify Firewall Script Location/Name
        A...........................  Customise External Address Space and Device
        3...........................  Customise Internal Address Space and Device      
        T...........................  Configure TCP Services
        U...........................  Configure UDP Services
        I...........................  Configure ICMP Services
        C...........................  Show Current Settings

MENU
   echo -n '      Press  letter for choice, then Return > '
}
