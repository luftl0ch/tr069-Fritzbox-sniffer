# tr069-Fritzbox-sniffer
Script to sniff the tr069 communication between your Fritzbox and your provider.


## Usage

1. Clone `git clone https://github.com/luftl0ch/tr069-Fritzbox-sniffer.git`
2. Change the login credentials of your Fritzbox in the script.
3. Set executable bit `chmod +x tr069-fritzdump.sh`
4. Start `./tr069-fritzdump.sh`

After a few minutes(!) you should find a fritzdump.pcap capture in the script directory.


## Comments

- This script filters away all unnecessary data packets in comparison to the original fritzdump script. 
- Every hour the script authenticates again on the fritzbox to prevent an automated logout and abort of the sniff. 
- If you want to sniff something other than tr069, you can also change the network port in the script. 
- All large pcap raw data located under /tmp/fritzdumps will be deleted every minute. 
- The cleaned recordings are located under striped-sniffs/ and are not deleted automatically. This can be activated in the script if you wish. 
- With mergecap we merge all clean single files into one big fritzdump.pcap.
- For security reasons, it is absolutely not recommended to sniff from your own computer. Wireshark and tshark frequently have high security vulnerabilities. For your security, please only run the program on a separate computer that can be pwned from time to time.


## Greetings

I have stolen a part of the script from here: 

[https://github.com/ntop/ntopng/blob/dev/tools/fritzdump.sh](https://github.com/ntop/ntopng/blob/dev/tools/fritzdump.sh)

Big thanks to the contributors of the fritzdump script!
