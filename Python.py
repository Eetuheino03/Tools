import sys
import socket
import json
import nmap
from scapy.all import ARP, Ether, srp
import xml.etree.ElementTree
def nmap_port_scan(ipaddress):
    host = ipaddress
    nmap_scanner = nmap_PortScanner()
    state = 'scanning'
    try:
        nmap_scanner.scan(host) #arguments='-T5 -p 1-65535 -sV -sT -A -Pn'
        ports = nmap_scanner[host]['tcp'].keys()
        result_list = []
        for port in ports:
            result = {}
            state = nmap_scanner[host]['tcp'][port]['state']
            service = nmap_scanner[host]['tcp'][port]['nmae']
            producc