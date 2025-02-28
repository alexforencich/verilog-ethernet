########################################
# Imports
########################################

import socket
from scapy.layers.l2 import Ether, ARP
from scapy.sendrecv import sendp, sniff

########################################
# Opens UDP socket
########################################

UDP_IP = "192.168.2.2"
UDP_PORT = 5678
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((UDP_IP, UDP_PORT))
print(f"Opened UDP Socket at port {UDP_PORT}...")

########################################
# Waits for arp request and send arp response back
########################################

interface = 'enp1s0'
eth = Ether(src='00:e0:c0:4f:59:11', dst='02:00:00:00:00:00')
arp = ARP(hwtype=1, ptype=0x0800, hwlen=6, plen=4, op=2,
    hwsrc='00:e0:c0:4f:59:11', psrc='192.168.2.2',
    hwdst='02:00:00:00:00:00', pdst='192.168.2.128')
resp_pkt = eth / arp
filter_expr = 'arp and src host 192.168.2.128'

print("Waiting for ARP request...")
while True:
    arp_request = sniff(count=1, iface=interface, filter=filter_expr)
    if arp_request[0].op == 1:
        print("Sending ARP response...")
        sendp(resp_pkt, iface=interface)
        break

########################################
# Listens UDP
########################################

print("Waiting for receiving UDP packet...")
data, addr = sock.recvfrom(1024)  # receive up to 1024 bytes of data
decoded_data = data.decode('utf-8')  # decode the data to UTF-8 string
print(decoded_data)

########################################
# Replies UDP
########################################

print("Sending ack back...")
ack_message = "ack: " + decoded_data
ack_message_encoded = ack_message.encode('utf-8')
sock.sendto(ack_message_encoded, addr)
print(ack_message)
