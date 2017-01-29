#!/bin/bash

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

        R...........................  Run Firewall
        S...........................  Stop Firewall
        
        T...........................  Configure TCP Services
        U...........................  Configure UDP Services
        I...........................  Configure ICMP Services
        Q...........................  Quit

MENU
    echo -n '      Press  letter for choice, then Return > '
}
