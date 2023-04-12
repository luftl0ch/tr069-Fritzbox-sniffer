# tr069-Fritzbox-sniffer
Script to sniff the tr069 communication between your Fritzbox and your provider.


## Usage

1. Clone `git clone https://github.com/luftl0ch/tr069-Fritzbox-sniffer.git`
2. Change the login credentials of your Fritzbox in the script.
3. Set executable bit `chmod +x tr069-fritzdump.sh`
4. Start `./tr069-fritzdump.sh`

After a **few minutes**(!) you should find a fritzdump.pcap capture in the script directory.

With curl you can make a request to test the script `curl EXTERNAL_FRITZ_IP:8089` - 
Make sure that the request reaches the Fritzbox via an external network. (mobile network, VPS server, ...)

## Dependencies

Some tools from wireshark (dumpcap, tshark). Everything should be included in the package wireshark-cli. `pacman -S wireshark-cli`

## How to find out which ports are used (Fritzbox)

1. Back up the router configuration. Webinterface: `System` -> `Sicherung`
2. Open the file with any editor and you should find the following block:

```
tr069cfg {
        enabled = yes;
        litemode = no;
        tr181_support = no;
        dhcp43_support = yes;
        igd {
                DeviceInfo {
                        FirstUseDate = "REMOVED";
                }
                managementserver {
                        url = "http://REMOVED:8443/tr069Service/REMOVED/REMOVED";
                        username = "REMOVED";
                        password = "REMOVED";
                        URLAlreadyContacted = yes;
                        FirstConnectDelay = 120;
                        LastInformReq = "REMOVED";
                        LastSuccessfulContact = "REMOVED";
                        URLbyDHCPIface = "";
                        PeriodicInformEnable = yes;
                        PeriodicInformInterval = 150;
                        PeriodicInformTime = "1970-01-01 00:00:00";
                        UpgradesManaged = no;
                        ACSInitiationEnable = yes;
                        ACSInitiationPorts = "8089+0";
                        SessionTerminationWithEmptyPost = no;
                        ConnectionRequestUsername = "";
                        ConnectionRequestPassword = "";
                        dnsprefer = tr069dnsprefer_ipv4;
                        CRSecurityEnable = no;
                        CRSecurityDNSUpdateInterval = 86400;
                        AllowedAccessMedium = tr069_medium_all;
                }
        }
        FirmwareDownload {
                enabled = yes;
                enabled_converted = yes;
                upload_enabled = no;
                valid = no;
                wifi_env_permission = wifi_env_permission_none;
                suppress_notify = no;
                status = 0;
                StartTime = "1970-01-01 00:00:00";
                CompleteTime = "1970-01-01 00:00:00";
                method = Download_Method_DL;
        }
        RebootRequest = no;
        RebootRequest_CommandKey = "";
        ACS_SSL {
                verify_server = no;
        }
        Download_SSL {
                verify_server = no;
        }
        guimode = guimode_hidden;
        tr069cookie = "";
        lab {
                Enable = no;
                URLAlreadyContacted = no;
                PeriodicInformInterval = 0;
                Features = 65534;
                CompressionMethod = http_compression_method_gzip;
                DDNS {
                        enabled = no;
                }
        }
}
```

Here you can extrakt useful informations about the tr-069 configuration. As you can see in my example, my provider "fortunately" does not use https encryption to their ACS server. The tr069 port on my Router (CPE) whos reachable from the WAN listen on Port 8089. The provider server (ACS) listening on 8443.

## Comments

- This script filters away all unnecessary data packets in comparison to the original fritzdump script. 
- Every hour the script authenticates again on the fritzbox to prevent an automated logout and abort of the sniff. 
- If you want to sniff something other than tr069, you can also change the network port in the script. 
- All large pcap raw data located under /tmp/fritzdumps will be deleted every minute. 
- The cleaned recordings are located under striped-sniffs/ and are not deleted automatically. This can be activated in the script if you wish. 
- With mergecap we merge all clean single files into one big fritzdump.pcap.
- For security reasons, it is absolutely not recommended to sniff from your own computer. Wireshark and tshark frequently have high security vulnerabilities. For your security, please only run the program on a separate computer that can be pwned from time to time.


## Greetings

Some parts of the code i stole from the fritzdump script:

[https://github.com/ntop/ntopng/blob/dev/tools/fritzdump.sh](https://github.com/ntop/ntopng/blob/dev/tools/fritzdump.sh)

Big thanks to the contributors of the fritzdump script!
