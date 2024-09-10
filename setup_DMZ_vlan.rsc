### Create DMZ VLAN on LAN Bridge (bridge1)
/interface vlan add name=vlan99_dmz vlan-id=99 interface=bridge1
/ip address add address=192.168.99.1/24 interface=vlan99_dmz

### Create DHCP Pool for DMZ VLAN
/ip pool add name=dmz_pool ranges=192.168.99.100-192.168.99.200
/ip dhcp-server network add address=192.168.99.0/24 gateway=192.168.99.1 dns-server=1.1.1.2,9.9.9.9
/ip dhcp-server add name=dhcp_dmz interface=vlan99_dmz address-pool=dmz_pool lease-time=31d
/ip dhcp-server enable dhcp_dmz

### Configure Firewall Rules for DMZ VLAN
/ip firewall filter add chain=forward action=accept connection-state=established,related in-interface=vlan99_dmz comment="Allow DMZ established connections"
/ip firewall filter add chain=forward action=accept in-interface=vlan99_dmz out-interface=pppoe-out1 comment="Allow DMZ traffic to WAN"
/ip firewall filter add chain=forward action=drop connection-state=invalid in-interface=vlan99_dmz comment="Drop invalid connections from DMZ"
/ip firewall filter add chain=forward action=drop in-interface=vlan99_dmz comment="Drop any other traffic from DMZ"

# NAT for DMZ
/ip firewall nat add chain=srcnat out-interface=pppoe-out1 action=masquerade src-address=192.168.99.0/24 comment="NAT for DMZ VLAN"

### Add a simple Queue for DMZ (FTTP speeds) with highest priority
/queue simple add comment="The DMZ Network" max-limit=120M/900M name=DMZQ priority=1/1 target=vlan99_dmz