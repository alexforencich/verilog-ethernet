#!/usr/bin/env python
"""
UDP echo test
"""

import argparse
import socket

def main():
    parser = argparse.ArgumentParser(description=__doc__.strip())
    parser.add_argument('host', help="Host")
    parser.add_argument('port', help="UDP port", nargs='?', type=int, default=1234)
    parser.add_argument('-n', help="Number of packets", type=int, default=1000)

    args = parser.parse_args()
    
    host = args.host
    port = args.port
    n = args.n
    
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.settimeout(0)
    
    sent = 0
    recv = 0
    
    data = b'testing'*100
    
    print(f"Sending {n} UDP packets to {host} on {port}...")
    
    while sent < n:
        try:
            sock.sendto(data, (host, port))
            sent += 1
        except BlockingIOError:
            pass
        
        try:
            ret = sock.recvfrom(1024)
            recv += 1
        except BlockingIOError:
            pass

    sock.settimeout(1)
    
    while True:
    
        try:
            ret = sock.recvfrom(1024)
            recv += 1
        except socket.timeout:
            break
    
    print(f"Sent {sent} packets")
    print(f"Received {recv} packets ({recv/sent*100}%)")
    print(f"Missed {sent-recv} packets ({(sent-recv)/sent*100}%)")


if __name__ == "__main__":
    main()
