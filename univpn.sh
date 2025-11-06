#!/bin/bash

# Options
SPLIT=false
NOTP=false

# Check if any arguments are provided
if [ "$#" -eq 0 ]; then
	echo "No arguments provided. Continuing with default options (use -h for help)"
else
	for arg in "$@"
		do
			case $arg in
				-s|--split)
					SPLIT=true
					;;
				-n|--notp|--manual)
					NOTP=true
					;;
				-h|--help)
					echo "openconnect implementation of the Uni VPN. \nDue to a bug in current packages, Openconnect does not correctly negotiate TLS down to 1.2, so we have to manually set it in the command. \nMost Network Managers do not offer that option, so i created a small helper script to automate this. \n\nOptions: \n\t -s, --split: Use the split tunnel option (by appending @split.uni-heidelberg.de to your username, see the VPN FAQs on the Uni Website) \n\t -n, --notp, --manual: Do not require a Token Secret to be stored in the kwallet, use the normal input during connection. Due to system limitations, also requires manual password input. \n\t -h, --help: Display this help text"
					exit
					;;
				*)
					echo "Unknown argument: $arg"
					;;
			esac
		done
fi

# Common Secrets
VPN_USERNAME=$(kwallet-query -r USER kdewallet -f vpn)
if [ $SPLIT = true ]; then # Change Username to use split config
    echo "[II] Using Split Tunnel"
		VPN_USERNAME=$VPN_USERNAME"@split.uni-heidelberg.de"
fi
if [ $NOTP = true ]; then # Connect without TOTP Generation, early return/exit
    echo "[II] Using Manual Password + TOTP Entry"
	 sudo openconnect --gnutls-priority="NORMAL:-VERS-ALL:+VERS-TLS1.2" --protocol=anyconnect --useragent='AnyConnect' -u $VPN_USERNAME vpn-ac.uni-heidelberg.de
	exit
fi

# Get Pass+Token, then connect, using Username as modified or not by split
VPN_PASSWD=$(kwallet-query -r PASS kdewallet -f vpn)
TOKEN_SECRET=$(kwallet-query -r TOKEN kdewallet -f vpn)
echo $VPN_PASSWD |sudo openconnect --gnutls-priority="NORMAL:-VERS-ALL:+VERS-TLS1.2" --protocol=anyconnect --useragent='AnyConnect' -u $VPN_USERNAME --token-mode=totp --token-secret=base32:$TOKEN_SECRET vpn-ac.uni-heidelberg.de --passwd-on-stdin
