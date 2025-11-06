# About
This repo has two scripts, "univpn.sh" which uses the kdewallet system to store user secrets, and "command-only.sh" which starts only the connection but requires manual input of username, password and one time token.

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
