# Alternatives
You can also move your openconnect binary to openconnect-bin, then create a sh script in its place with 
```
#!/bin/sh
 
/usr/sbin/openconnect-bin "$@" --gnutls-priority="NORMAL:-VERS-ALL:+VERS-TLS1.2"
```
This should even work with Network Manager and other tools that use openconnect to facilitate VPN connections. (However, you might need to reboot)

# Do I need this?
If you cannot connect with plain openconnect (per command or NetworkManager), specifically with the error
```
Got inappropriate HTTP CONNECT response: HTTP/1.1 401 Unauthorized
Creating SSL connection failed
Cookie was rejected by server; exiting.
```
this is likely because of an error with TLS negotiation. 
You can use the --gnutls-priority flag of openconnect to force TLS1.2, which should fix the problem. (See Status of openconnect below)
This error will only happen after you correctly logged in. If your connection fails because of "Login Failed" after inputting your credentials, it is likely not a problem with TLS but rather your credentials. Ensure you can login with username and password on heiCO, and your TOTPs correctly function in the Test function on the MFA Page (without VPN only from within University Networks, of course).

# Status of openconnect and TLS
Connections failing because of TLS Errors look identical to working ones until after you logged in. (They will show "`connected [] with ciphersuite (TLS1.X)-...`" in the logs, where 1.3 should never work due to the error. However, sometimes NetworkManager Logs show 1.3 even when using the openconnect script from above, in which case it will work, because it is actually 1.2. I have no idea what is happening here)
See the [openconnect](https://gitlab.com/openconnect/openconnect/-/issues/730) [bug reports](https://gitlab.com/openconnect/openconnect/-/issues/659).
I have personally tested openconnect v9.01-3 and v9.12-3 from debian 12 and 13, respectively, and they have not fixed the problem yet.
If you have a newer version feel free to contribute the Status. (In the discussions Tab)

# About
This repo has two scripts, "univpn.sh" which uses the kdewallet system to store user secrets, and "command-only.sh" which starts only the connection but requires manual input of username, password and one time token.

# command-only.sh
Only has the barebones command to get a connection. Tested with openconnect version v9.01-3 as of 20.11.2025.

# univpn.sh
The univpn.sh command provides two switches, --split, which activates split vpn functionality, such that only University Connections are re-routed, and --notp which disables automatic TOTP generation (no need for TOTP Secret in KDEWallet), but due to limitations also requires manual password entry.

## Setup
To use it, please use kwalletmanager to add the relevant entries (case sensitive):
[walletname] (kdewallet for most)
|- vpn
    |- Passwords
        |- USER -> Uni-ID (no email, no suffixes, only 5 char ID)
        |- PASS -> Passwords as used in heiCO and other Uni-ID logins
        |- TOKEN -> base32 encoded TOTP Secret

(To create this structure, choose your wallet, go to the Folders section, add a new folder "vpn", choose the "Passwords" Entry in the Folder, then add three entries as above. On the right side you will then have the entry you selected in the Passwords subfolder on the left. Click on Show Contents, which will open a Text Field where you can input your values.)

## TOTP Secret
If you don't already know how to get the secret (meaning used it in a password manager like KeePassXC where you have to add it manually and can later also look at the totp URL later), here is a quick guide to create a new one just for the VPN.
On the MFA Website where you created your TOTP (Google Authenticator or similar App), you can create a new one. Instead of Scanning the QR Code, use the link / text option (usually hidden by default). There you will receive a text similar to `otpauth://totp/uni%20vpn%20mfa:none?secret={multiple random Letters}&period=30&digits=6&issuer=uni%20vpn%20mfa`. Copy the characters between `secret=` and `&` and save them under TOKEN. You probably don't want to save this link anywhere unprotected, so either just copy the secret into kwallet, or store the entire link in a safe place like an encrypted file or password manager.
