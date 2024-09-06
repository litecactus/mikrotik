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

# DHCP and DNS Setup
/ip pool add name=dhcp_pool ranges=192.168.88.10-192.168.88.254
/ip dhcp-server network add address=192.168.88.0/24 gateway=192.168.88.1 dns-server=1.1.1.2,9.9.9.9
/ip dns set servers=1.1.1.2,9.9.9.9 allow-remote-requests=yes
/ip dhcp-server add name=dhcp1 interface=bridge1 address-pool=dhcp_pool lease-time=1d
/ip dhcp-server enable dhcp1

# WAN PPPoE Client
/interface pppoe-client add name=pppoe-out1 disabled=no interface=ether8 user=bthomehub@btbroadband.com password=password add-default-route=yes use-peer-dns=yes

# FIREWALL INPUT CHAIN - Handles traffic destined for the router itself
add chain=input action=accept connection-state=established,related,untracked comment="Accept established, related, untracked connections"
add chain=input action=accept protocol=icmp comment="Accept ICMP"
add chain=input action=drop connection-state=invalid comment="Drop invalid connections"
add chain=input action=drop in-interface=ether8 comment="Drop all other traffic on WAN interface"

# FIREWALL FORWARD CHAIN - Handles traffic passing through the router
add chain=forward action=fasttrack-connection connection-state=established,related comment="Fasttrack for established, related connections"
add chain=forward action=accept connection-state=established,related comment="Accept established, related connections"
add chain=forward action=drop connection-state=invalid comment="Drop invalid connections"
add chain=forward action=drop connection-state=new connection-nat-state=!dstnat in-interface=ether8 comment="Drop traffic from WAN to LAN not NATed"

# FIREWALL OUTPUT CHAIN - Handles traffic originating from the router itself (usually less restrictive)
add chain=output action=accept connection-state=established,related comment="Accept established, related connections"
add chain=output action=drop connection-state=invalid comment="Drop invalid connections"

# FIREWALL Logging - For troubleshooting and monitoring
add chain=input action=log log-prefix="INPUT DROP: " comment="Log dropped INPUT traffic"
add chain=forward action=log log-prefix="FORWARD DROP: " comment="Log dropped FORWARD traffic"

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
