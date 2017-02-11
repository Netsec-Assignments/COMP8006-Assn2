#Testing SYN Packets coming the wrong way.
echo "Testing incoming SYN on disallowed port, should be 100% loss"
hping3 $EXTERNAL_IP -c 5 -p 1025 -S

#Testing TELNET packets
echo "Testing TELNET dest port, should be 100% loss"
hping3 $EXTERNAL_IP -c 5 -p 23 -S
echo "Testing TELNET source port, should be 100% loss"
hping3 $EXTERNAL_IP -c 5 -s 23 -S

#Testing DROP on all TCP connections that send SYN, FIN,
echo "Testing DROP on all TCP connections that send SYN-FIN, should be 100% loss"
hping3 $EXTERNAL_IP -S -F -c 5 -p 80

#Testing UDP drop on 32768-32775
for i in 32768 32769 32770 32771 32772 32773 32774 32775
do
    echo "Testing drop incoming UDP between 32768-32775 ($i), should be 100% loss"
    hping3 $EXTERNAL_IP --udp -c 5 -p $i
done

#Testing TCP drop on 137-139
for i in 137 138 139
do
    echo "Testing drop incoming UDP between 137-139, should be 100% loss"
    hping3 $EXTERNAL_IP --udp -c 5 -p $i
done

#Testing TCP drop on 515
echo "Testing drop incoming TCP on port 515, should be 100% loss"
hping3 $EXTERNAL_IP -S -c 5 -p 515

#Testing TCP drop on 111
echo "Testing drop incoming TCP on port 111, should be 100% loss"
hping3 $EXTERNAL_IP -S -c 5 -p 111

#Testing TCP drop on 32768-32775
for i in 32768 32769 32770 32771 32772 32773 32774 32775
do
    echo "Testing drop incoming TCP between 32768-32775 ($i), should be 100% loss"
    hping3 $EXTERNAL_IP -S -c 5 -p $i
done

#Testing TCP drop on 137-139
for i in 137 138 139
do
    echo "Testing drop incoming TCP between 137-139 ($i), should be 100% loss"
    hping3 $EXTERNAL_IP -S -c 5 -p $i
done
