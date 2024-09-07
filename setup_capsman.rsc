### A standard setup for Capsman wifi
### Called via main MikroTik script or can be run manually after setup or "quickset"
### Edit the xxx to your desired Wi-Fi and SSID details

### Enable CAPsMAN and Create Configuration
/caps-man manager set enabled=yes
#/caps-man manager set interfaces=bridge1

### Configure Security Profiles for Main and Guest Wi-Fi
# edit me
/caps-man security add name=private_sec authentication-types=wpa2-psk encryption=aes-ccm passphrase=xxxxxxxxxx
/caps-man security add name=guest_sec authentication-types=wpa2-psk encryption=aes-ccm passphrase=xxxxxxxxxx

### Create Data Paths for Main and Guest Wi-Fi
/caps-man datapath add name=wifi_private_datapath bridge=bridge1
/caps-man datapath add name=wifi_guest_datapath bridge=bridge1 vlan-id=101 vlan-mode=use-tag

### Create Configuration Profiles for Main and Guest Wi-Fi
# edit me
/caps-man configuration add name=wifi_private_config ssid=xxxx security=private_sec datapath=wifi_private_datapath country="united kingdom"
/caps-man configuration add name=wifi_guest_config ssid=xxxx security=guest_sec datapath=wifi_guest_datapath country="united kingdom"

### 6. Configure Provisioning for CAPs
/caps-man provisioning add action=create-dynamic-enabled master-configuration=wifi_private_config slave-configurations=wifi_guest_config name-prefix=AP