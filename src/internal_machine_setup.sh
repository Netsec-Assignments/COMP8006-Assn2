STATIC_IP="10.0.4.2"
GATEWAY_IP="10.0.4.1"

# ip link set eno1 down
ip addr add $STATIC_IP 
ip link set eno1 up
ip route add default via $GATEWAY_IP
