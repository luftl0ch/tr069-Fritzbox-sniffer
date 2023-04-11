#!/bin/bash
# Something I have stolen here. Thanks to all contributors of the following Script!
#https://github.com/ntop/ntopng/blob/dev/tools/fritzdump.sh

# !!! Configure the credentials. If you use password-only authentication use 'dslf-config' as username.
FRITZUSER=CHANGEME!
FRITZPWD=CHANGEME!

# (Everything down here is optional)
#-------------------------------------------
# The address of the router
FRITZIP=http://192.168.178.1

# This should be the WAN Interface of the Fritzbox (7490)
IFACE="2-1"

# Port to monitor Traffic. tr069 works by default on port 8089
tcpport="8089"
#-------------------------------------------
SIDFILE="/tmp/fritz.sid"
dumpdirectory="/tmp/fritzdumps"
stripeddirectory="striped-sniffs"
finaldump="fritzdump.pcap"

touch $finaldump
mkdir -p $dumpdirectory
mkdir -p striped-sniffs

i=-1
timer=360 # After how many 10 second rounds should the sniffer be restarted. 360 x 10 sec = every hour
while true; do
	sleep 10
	i=$((i+1)) # timer +1
    # pcap clean up recordings from /tmp every minute and merge them into fritzdump.pcap
    for file in $(find "$dumpdirectory" -type f -name "*.pcap" -mmin +1); do
    stripedfile="$(echo $file | sed 's/.pcap$/.striped.pcap/' | xargs basename)" # append .striped.pcap to the filename
    tshark -Y "tcp.port == $tcpport "  -r $file -w "striped-sniffs/$stripedfile" -t ad # Clean file with tshark and move to striped-sniffs/
    echo "Die Datei $file wurde konvertiert und als $stripeddirectory/$stripedfile gespeichert."
    rm "$file" # Delete the old pcap files
    mergecap   "$stripeddirectory/$stripedfile" "$finaldump" -w "$finaldump" # Append the cleaned up recordings to fritzdump.pcap
    #rm "$stripeddirectory/$stripedfile" # Optionally clean files under striped-sniffs/ automatically
    find $stripeddirectory -type f -name "*.pcap" -size -500c -delete # Delete empty pcap files with a size smaller than 500 bytes
    done
   echo "Sniff restart timer: $i ($timer)"	
	if [ $i -eq $timer ] || [ $i -eq 0 ]; then
    pkill wget # Kill old sniff session
    sleep 1
      # Start Fritzbox sniffer
      if [ -z "$FRITZPWD" ] || [ -z "$FRITZUSER" ]  ; then echo "Username/Password empty. Usage: $0 <username> <password>" ; exit 1; fi

      echo "Trying to login into $FRITZIP as user $FRITZUSER"

      if [ ! -f $SIDFILE ]; then
        touch $SIDFILE
      fi

      SID=$(cat $SIDFILE)

      # Request challenge token from Fritz!Box
      CHALLENGE=$(curl -k -s $FRITZIP/login_sid.lua |  grep -o "<Challenge>[a-z0-9]\{8\}" | cut -d'>' -f 2)

      # Very proprieatry way of AVM: Create a authentication token by hashing challenge token with password
      HASH=$(perl -MPOSIX -e '
          use Digest::MD5 "md5_hex";
          my $ch_Pw = "$ARGV[0]-$ARGV[1]";
          $ch_Pw =~ s/(.)/$1 . chr(0)/eg;
          my $md5 = lc(md5_hex($ch_Pw));
          print $md5;
        ' -- "$CHALLENGE" "$FRITZPWD")
        curl -k -s "$FRITZIP/login_sid.lua" -d "response=$CHALLENGE-$HASH" -d 'username='${FRITZUSER} | grep -o "<SID>[a-z0-9]\{16\}" | cut -d'>' -f 2 > $SIDFILE

      SID=$(cat $SIDFILE)

      # Check for successfull authentification
      if [[ $SID =~ ^0+$ ]] ; then echo "Login failed. Did you create & use explicit Fritz!Box users?" ; exit 1 ; fi

      echo "Capturing traffic on Fritz!Box interface $IFACE ..." 1>&2

      # Start Sniff
      wget --no-check-certificate -qO- $FRITZIP/cgi-bin/capture_notimeout?ifaceorminor=$IFACE\&snaplen=\&capture=Start\&sid=$SID |  tshark -t ad -w $dumpdirectory/fritzsniffraw.pcap  -b duration:59 -i  - &
  i=0

	fi
done