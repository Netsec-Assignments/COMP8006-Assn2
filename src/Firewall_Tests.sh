###################################################################################################
# File: 
#  Firewall_Tests.sh
# Developers
#  Mat Siwoski
#  Shane Spoor
# Date created:
#  1/22/2017
# Description:
#  To test the firewall settings.
###################################################################################################

#!/bin/bash

#DEFAULT VALUES
EXTERNAL_IP="192.168.0.6"
OUTSIDE_NETWORK_IP = "192.168.1.60"


#Show the settings 
nmap -T4 -A -v $EXTERNAL_IP

#################################################TCP###############################################

#Testing TCP Packets on Port 22
echo "Testing TCP Packets on Allowed Port 22, should be 0% loss"
hping3 $EXTERNAL_IP -c 5 -S -p 22

#Testing TCP Packets on Port 80
echo "Testing TCP Packets on Allowed Port 80, should be 0% loss"
hping3 $EXTERNAL_IP -c 5 -S -p 80

#Testing TCP Packets on Port 443
echo "Testing TCP Packets on Allowed Port 443, should be 0% loss"
hping3 $EXTERNAL_IP -c 5 -S -p 443

#Testing TCP Packets on Port 111
echo "Testing TCP Packets on Unallowed Port 111, should be 100% loss"
hping3 $EXTERNAL_IP -c 5 -S -p 111

#################################################UDP###############################################

#Testing UDP Packets on Port 22
echo "Testing UDP Packets on Allowed Port 22, should be 0% loss"
hping3 $EXTERNAL_IP --udp -c 5 -p 22

#Testing UDP Packets on Port 137
echo "Testing UDP Packets on Allowed Port 137, should be 0% loss"
hping3 $EXTERNAL_IP --udp -c 5 -p 137

################################################ICMP###############################################

#Testing ICMP packets
echo "Testing ICMP packets, should be 0% loss"
ping $EXTERNAL_IP -c 5 

#Testing ICMP by spoofing network address outside internal network
echo "Spoofing ICMP network address outside internal network, should be 100% loss"
hping3 $EXTERNAL_IP -c 5 --spoof $OUTSIDE_NETWORK_IP

#Testing ACCEPT fragments.
echo "Testing ACCEPT fragments, should be 0% loss"
hping3 $EXTERNAL_IP -c 5 -f -p 443 -d 200 -S

#Testing SYN Packets coming the wrong way.
echo "Spoofing ICMP network address outside internal network, should be 100% loss"
hping3 $EXTERNAL_IP -c 5 -p 1025 -S


