### A standard setup for a Guest VLAN on LAN bridge1
### Called via main MikroTik script or can be run manually after setup or "quickset"
### Guest VLAN 101 - allows tagged traffic from an access point 
### NO ACCESS TO LAN, FULL ACCESS TO INTERNET - suitable for IOT devices

### Create Guest VLAN LAN
/interface vlan add name=vlan101_guest vlan-id=101 interface=bridge1
/ip address add address=192.168.101.1/24 interface=vlan101_guest
/ip dhcp-server network add address=192.168.101.0/24 gateway=192.168.101.1 dns-server=1.1.1.2,9.9.9.9
/ip pool add name=guest_pool ranges=192.168.101.10-192.168.101.254
/ip dhcp-server add name=dhcp_guest interface=vlan101_guest address-pool=guest_pool lease-time=1d
/ip dhcp-server enable dhcp_guest

### Firewall and NAT
/ip firewall filter add chain=forward action=accept connection-state=established,related in-interface=vlan101_guest comment="Allow Guest VLAN established connections"
/ip firewall filter add chain=forward action=drop in-interface=vlan101_guest out-interface=bridge1 comment="Drop Guest VLAN access to main LAN"
/ip firewall filter add chain=forward action=drop connection-state=invalid in-interface=vlan101_guest comment="Drop invalid connections from Guest VLAN"
/ip firewall nat add chain=srcnat out-interface=pppoe-out1 action=masquerade src-address=192.168.101.0/24 comment="NAT for Guest VLAN"