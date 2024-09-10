### Set timezone and NTP for UK
/system clock set time-zone-name=Europe/London
/system ntp client set enabled=yes servers=0.uk.pool.ntp.org

### LAN Create and configure bridge
/interface bridge add name=bridge1 auto-mac=no admin-mac=78:9A:18:54:30:53 
/ip address add address=192.168.88.1/24 interface=bridge1
/interface bridge port add interface=ether1 bridge=bridge1
/interface bridge port add interface=ether2 bridge=bridge1
/interface bridge port add interface=ether3 bridge=bridge1
/interface bridge port add interface=ether4 bridge=bridge1
# Comment these next three lines out for a hEX
/interface bridge port add interface=ether5 bridge=bridge1
/interface bridge port add interface=ether6 bridge=bridge1
/interface bridge port add interface=ether7 bridge=bridge1

### DHCP and DNS Setup on 88.0 network with Quad9 and Cloudflare anti-malware DNS servers
/ip pool add name=dhcp_pool ranges=192.168.88.10-192.168.88.254
/ip dhcp-server network add address=192.168.88.0/24 gateway=192.168.88.1 dns-server=1.1.1.2,9.9.9.9
/ip dns set servers=1.1.1.2,9.9.9.9 allow-remote-requests=yes
/ip dhcp-server add name=dhcp1 interface=bridge1 address-pool=dhcp_pool lease-time=1d
/ip dhcp-server enable dhcp1

### WAN PPPoE Client - UK BT Broadband username and password already set, change for your PPPoE details
# Change interface=ether8 to interface=ether5 for a hEX
/interface pppoe-client add name=pppoe-out1 disabled=no interface=ether8 user=bthomehub@btbroadband.com password=password add-default-route=yes use-peer-dns=yes
/ip firewall nat add chain=srcnat out-interface=pppoe-out1 action=masquerade

### FIREWALL INPUT CHAIN - Handles traffic destined for the router itself
/ip firewall filter add chain=input action=drop connection-state=invalid comment="Drop invalid connections"
/ip firewall filter add chain=input action=drop in-interface=pppoe-out1 comment="Drop all other traffic on WAN interface"
/ip firewall filter add chain=input action=accept connection-state=established,related,untracked comment="Accept established, related, untracked connections"
/ip firewall filter add chain=input action=accept protocol=icmp comment="Accept ICMP"
/ip firewall filter add chain=input action=accept dst-address=127.0.0.1 comment="Accept to local loopback (for CAPsMAN)"

### FIREWALL FORWARD CHAIN - Handles traffic passing through the router
/ip firewall filter add chain=forward action=fasttrack-connection connection-state=established,related comment="Fasttrack for established, related connections"
/ip firewall filter add chain=forward action=accept connection-state=established,related comment="Accept established, related connections"
/ip firewall filter add chain=forward action=drop connection-state=invalid comment="Drop invalid connections"
/ip firewall filter add chain=forward action=drop connection-state=new connection-nat-state=!dstnat in-interface=pppoe-out1 comment="Drop traffic from WAN to LAN not NATed"

### FIREWALL OUTPUT CHAIN - Handles traffic originating from the router itself (usually less restrictive)
/ip firewall filter add chain=output action=accept connection-state=established,related comment="Accept established, related connections"
/ip firewall filter add chain=output action=drop connection-state=invalid comment="Drop invalid connections"

### FIREWALL Logging - For troubleshooting and monitoring
/ip firewall filter add chain=input action=log log-prefix="INPUT DROP: " comment="Log dropped INPUT traffic"
/ip firewall filter add chain=forward action=log log-prefix="FORWARD DROP: " comment="Log dropped FORWARD traffic"

### Configure Interface List and MAC Server
/interface list add name=LAN
/interface list member add list=LAN interface=bridge1
/tool mac-server set allowed-interface-list=LAN
/tool mac-server mac-winbox set allowed-interface-list=LAN
/ip neighbor discovery-settings set discover-interface-list=LAN

# Configure User and Services
/ip service disable telnet,ftp,www,api,ssh
/ip service set winbox address=192.168.88.0/24
/tool bandwidth-server set enabled=no

### SETUP GUEST VLAN
# Comment out if you don't need a guest VLAN
/import setup_guest_vlan.rsc

### SETUP DMZ VLAN
# Comment out if you don't need a guest VLAN
/import setup_DMZ_vlan.rsc

### SETUP CAPSMAN
# Comment out if you don't need wifi via capsman
/import setup_capsman_private.rsc

### Add a simple Queue for LAN (FTTP speeds) medium priority
/queue simple add comment="My Network" max-limit=120M/900M name=LANQ priority=5/5 target=192.168.88.0/24
