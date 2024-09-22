/interface bridge add admin-mac=D4:01:C3:64:94:BB auto-mac=no name=bridge vlan-filtering=yes

# Creates the VLAN interfaces so IP address can be given out on access ports, requires DHCP servers setup on your router/interface vlan
add comment="dmz vlan" interface=bridge name=vlan99 vlan-id=99
add comment="guest vlan" interface=bridge name=vlan101 vlan-id=101

# Assigning the access ports to each port, 1&2 are Guest VLAN and 7&8 are DMZ VLAN, rest are default network VLAN1 - change for your layout as desired
/interface bridge port
add bridge=bridge comment=guest interface=ether1 pvid=101
add bridge=bridge comment=guest interface=ether2 pvid=101
add bridge=bridge comment=net interface=ether3
add bridge=bridge comment=net interface=ether4
add bridge=bridge comment=net interface=ether5
add bridge=bridge comment=net interface=ether6
add bridge=bridge comment=dmz interface=ether7 pvid=99
add bridge=bridge comment=dmz interface=ether8 pvid=99
add bridge=bridge comment=trunk interface=sfp-sfpplus1
# Path cost here specifically set for my network topology, you might want to comment that bit out
add bridge=bridge comment=trunk interface=sfp-sfpplus2 path-cost=8010

# Adding the VLAN tree - basically tagged = trunk ports (you need bridge in tagged so it has access to the CPU) and untagged = access ports
/interface bridge vlan
add bridge=bridge comment="guest VLAN" tagged=sfp-sfpplus1,sfp-sfpplus2,bridge untagged=ether1,ether2 vlan-ids=101
add bridge=bridge comment="DMZ VLAN" tagged=sfp-sfpplus1,sfp-sfpplus2,bridge untagged=ether7,ether8 vlan-ids=99

# Sets up the IP addresses of the switch, if you have multiple switches amend to .3 and then .4 etc etc
/ip address
add address=192.168.88.2/24 comment=defconf interface=bridge network=192.168.88.0
add address=192.168.101.2/24 comment=guest interface=vlan101 network=192.168.101.0
add address=192.168.99.2/24 comment=dmz interface=vlan99 network=192.168.99.0

# This will allow the switch itself to ping the internet and download updates, update time etc
/ip dns set servers=192.168.88.1
/ip route add disabled=no dst-address=0.0.0.0/0 gateway=192.168.88.1 routing-table=main suppress-hw-offload=no

# Sets NTP time for UK
/system clock set time-zone-name=Europe/London
/system ntp client set enabled=yes servers=0.uk.pool.ntp.org
/system ntp client servers add address=1.uk.pool.ntp.org
/system ntp client servers add address=2.uk.pool.ntp.org
/system ntp client servers add address=3.uk.pool.ntp.org