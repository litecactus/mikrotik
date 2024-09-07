### 1. Create VLAN Interface for Guest VLAN on Bridge
/interface vlan add name=vlan101_guest vlan-id=101 interface=bridge1

### 2. Add IP Address for Guest VLAN Network
/ip address add address=192.168.101.1/24 interface=vlan101_guest

### 3. Create a DHCP Pool for Guest VLAN
/ip pool add name=guest_pool ranges=192.168.101.10-192.168.101.254

### 4. Setup DHCP Server for Guest VLAN
/ip dhcp-server network add address=192.168.101.0/24 gateway=192.168.101.1 dns-server=1.1.1.2,9.9.9.9
/ip dhcp-server add name=dhcp_guest interface=vlan101_guest address-pool=guest_pool lease-time=1d
/ip dhcp-server enable dhcp_guest

### 5. Configure Firewall for Guest VLAN

# Allow guest VLAN to establish connections to the internet
/ip firewall filter add chain=forward action=accept connection-state=established,related in-interface=vlan101_guest comment="Allow Guest VLAN established connections"
# Drop guest VLAN access to the main LAN
/ip firewall filter add chain=forward action=drop in-interface=vlan101_guest out-interface=bridge1 comment="Drop Guest VLAN access to main LAN"
# Drop any invalid guest VLAN connections
/ip firewall filter add chain=forward action=drop connection-state=invalid in-interface=vlan101_guest comment="Drop invalid connections from Guest VLAN"

### 6. NAT for Guest VLAN Internet Access
/ip firewall nat add chain=srcnat out-interface=pppoe-out1 action=masquerade src-address=192.168.101.0/24 comment="NAT for Guest VLAN"
