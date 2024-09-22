/interface bridge add admin-mac=D4:01:C3:64:94:BB auto-mac=no name=bridge vlan-filtering=yes

/interface vlan
add comment="dmz vlan" interface=bridge name=vlan99 vlan-id=99
add comment="guest vlan" interface=bridge name=vlan101 vlan-id=101


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
add bridge=bridge comment=trunk interface=sfp-sfpplus2


/interface bridge vlan
add bridge=bridge comment="guest VLAN" tagged=sfp-sfpplus1,sfp-sfpplus2 untagged=ether1,ether2 vlan-ids=101
add bridge=bridge comment="DMZ VLAN" tagged=sfp-sfpplus1,sfp-sfpplus2,bridge untagged=ether7,ether8 vlan-ids=99


/ip address
add address=192.168.88.2/24 comment=defconf interface=bridge network=192.168.88.0
add address=192.168.101.2/24 comment=guest interface=vlan101 network=192.168.101.0
add address=192.168.99.2/24 comment=dmz interface=vlan99 network=192.168.99.0
/ip dns set servers=192.168.88.1

### Set timezone and NTP for UK
/system clock set time-zone-name=Europe/London
/system ntp client set enabled=yes servers=0.uk.pool.ntp.org
/system ntp client servers add address=1.uk.pool.ntp.org
/system ntp client servers add address=2.uk.pool.ntp.org
/system ntp client servers add address=3.uk.pool.ntp.org