# My Mikrotik quick start script
My mikrotik setup script for my RB5009UG+S+IN with WAN on port ether8 and LAN on ether1-7. I like to play and tend to break things regularly so creating this script will mean I can always get back to my "normal" or baseline super quickly. This is intended to be a simple setup for UK BT Broadband via PPPoE.

This script can easily be adapted for other Mikrotik devices with 5 ports like the hEX range by commenting out a few lines and changing the WAN port. I've marked this as # comments on the script.

I've added a router.rsc for your router and a switch.rsc for any network switches. The VLANs are trunked to the switch and I've manually set access ports for how I like them, you're setup may want to be different. Bear in mind I'm using a CRS3xxx switch so these VLANs are setup in the best way for that model. Other switch models may benefit from different setups!