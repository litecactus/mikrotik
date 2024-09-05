# Set timezone
/system clock set time-zone-name=Europe/London

# Set NTP server
/system ntp client set enabled=yes servers=0.uk.pool.ntp.org

# Create and configure bridge
/interface bridge add name=bridge1
/interface bridge port add interface=ether1 bridge=bridge1
/interface bridge port add interface=ether2 bridge=bridge1
/interface bridge port add interface=ether3 bridge=bridge1
/interface bridge port add interface=ether4 bridge=bridge1
/interface bridge port add interface=ether5 bridge=bridge1
/interface bridge port add interface=ether6 bridge=bridge1
/interface bridge port add interface=ether7 bridge=bridge1
/ip address add address=192.168.88.1/24 interface=bridge1

# Define DHCP Address Pool
/ip pool add name=dhcp_pool ranges=192.168.88.10-192.168.88.254

# Create a DHCP Network
/ip dhcp-server network add address=192.168.88.0/24 gateway=192.168.88.1 dns-server=1.1.1.2,9.9.9.9

# Configure the DHCP Server
/ip dhcp-server add name=dhcp1 interface=bridge1 address-pool=dhcp_pool lease-time=1d
/ip dhcp-server enable dhcp1

# Configure PPPoE Client
/interface pppoe-client add name=pppoe-out1 disabled=no interface=ether8 user=bthomehub@btbroadband.com password=password add-default-route=yes use-peer-dns=yes

# Configure Firewall Rules
/ip firewall nat add chain=srcnat out-interface=pppoe-out1 action=masquerade
/ip firewall filter add chain=input action=accept connection-state=established,related,untracked comment="Accept established, related, untracked connections"
/ip firewall filter add chain=input action=accept protocol=icmp comment="Accept ICMP"
/ip firewall filter add chain=input action=drop connection-state=invalid comment="Drop invalid connections"
/ip firewall filter add chain=input action=drop in-interface=pppoe-out1 comment="Drop all other traffic on WAN interface"
/ip firewall filter add chain=forward action=fasttrack-connection connection-state=established,related comment="Fasttrack for established, related connections"
/ip firewall filter add chain=forward action=accept connection-state=established,related comment="Accept established, related connections"
/ip firewall filter add chain=forward action=drop connection-state=invalid comment="Drop invalid connections"
/ip firewall filter add chain=forward action=drop connection-state=new connection-nat-state=!dstnat in-interface=pppoe-out1 comment="Drop traffic from WAN to LAN not NATed"
/ip firewall filter add chain=output action=accept connection-state=established,related comment="Accept established, related connections"
/ip firewall filter add chain=output action=drop connection-state=invalid comment="Drop invalid connections"

# Configure Interface List and MAC Server
/interface list add name=LAN
/interface list member add list=LAN interface=bridge1
/tool mac-server set allowed-interface-list=LAN
/tool mac-server mac-winbox set allowed-interface-list=LAN
/ip neighbor discovery-settings set discover-interface-list=LAN

# Configure User and Services
/ip service disable telnet,ftp,www,api
/ip service set winbox address=192.168.88.0/24
/tool bandwidth-server set enabled=no
